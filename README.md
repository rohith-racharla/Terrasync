# Terrasync - Terraform Drift Detection & Remediation

> **A zero-cost, production-grade Terraform drift detection and human-approved remediation system powered by GitHub Actions.**

---

## What Is Terraform Drift?

**Drift** occurs when real cloud infrastructure diverges from what Terraform's state file expects.

Common causes:

- Direct changes made in the AWS Console or CLI, bypassing Terraform
- External automation (runbooks, scripts) that modify managed resources
- AWS-managed changes such as EKS addon upgrades or auto-scaling events

Undetected drift leads to:

- Silent infrastructure inconsistencies
- Security vulnerabilities (unmanaged IAM changes, open SGs)
- Compliance failures

This system detects drift automatically every 6 hours, notifies via Slack and GitHub Issues, and provides a structured human-approved remediation workflow.

---

## Architecture

```

              GitHub Actions

  Schedule (every 6h) or workflow_dispatch
                    |
                    v
  discover job: find terraform/environments/ -> JSON matrix
                    |
                    v (matrix: fail-fast: false)
  +---------+  +-----------+  +----------+
  |   dev   |  |  staging  |  |   prod   |
  |         |  |           |  |          |
  | tf plan |  |  tf plan  |  |  tf plan |
  +---------+  +-----------+  +----------+
                    |
                    v (if exit code 2)
  notify job: GitHub Issue (per env, de-duped) + Slack message
                    |
                    v (human reviews and approves)
    drift-remediation.yml (workflow_dispatch)
    safety-gate (confirmation = REMEDIATE)
                    |
                    v
pre-flight plan -> apply or refresh-state -> post-check -> close issue
                    |
                    v (OIDC, no long-lived keys)
  AWS: EKS + VPC + IAM + ECR (per environment)
          S3 (state) + state locking

```

## How Drift Is Detected

The detection mechanism uses `terraform plan -detailed-exitcode`:

```
Exit 0  No changes. Infrastructure matches the configuration.
Exit 1  Terraform error. Pipeline fails.
Exit 2  Changes detected. Drift is present.
```

## Key Features

| Feature | Implementation |
| --- | --- |
| Drift detection | `terraform plan -detailed-exitcode` (exit code 2 => drift) |
| Parallel scanning | GitHub Actions matrix strategy, `fail-fast: false` |
| Dynamic environment discovery | `find terraform/environments` at runtime |
| No long-lived AWS keys | GitHub OIDC federated identity - temporary credentials only |
| Human-approval gate | Remediation requires typing `REMEDIATE` in the confirmation field |
| Dual notifications | GitHub Issue per environment (de-duplicated) and Slack Block Kit message |
| Smart PR checks | Plans only environments whose files changed - module change triggers all |
| Audit trail | Remediation runs record actor, mode, reason, and timestamp in the job summary |
| Post-remediation verification | Drift check re-runs after remediation to confirm the environment is clean |
| Security scanning | tfsec runs on every PR, results posted as PR comments |
| Cost estimation | Infracost estimates posted on PRs and committed as a README badge on push to main |

## Remediation Modes

| Mode | What it does | When to use |
| --- | --- | --- |
| `plan-only` | Shows what Terraform would change. No modifications made. | Review before committing to an action |
| `apply` | Runs `terraform apply`. Enforces desired configuration. | Undo an unintentional manual change |
| `refresh-state` | Runs `terraform apply -refresh-only`. Accepts current AWS reality into state. | Accept an intentional manual change |

Safety controls:
- Confirmation input must equal exactly `REMEDIATE`
- The `reason` field is required and recorded in the job summary for audit purposes
- A post-remediation drift check runs automatically to verify the environment is clean
- GitHub Issues are auto-closed when the post-check passes

---

## Infrastructure Overview

Each environment deploys an independent, production-grade EKS cluster:

| Component | Dev | Staging | Prod |
| --- | --- | --- | --- |
| EKS Version | 1.36 | 1.36 | 1.36 |
| Node Type | t3.small | t3.large | m5.large |
| Node Count | 1 (min 1, max 2) | 2 (min 1, max 4) | 3 (min 2, max 10) |
| Availability Zones | 2 | 2 | 3 |
| NAT Gateways | 1 | 1 | 3 (one per AZ) |
| VPC Flow Logs | No | Yes | Yes |
| Log Retention | 7 days | 14 days | 30 days |

Security controls applied to all environments:

- KMS encryption for EKS secrets at rest
- IMDSv2 required on all nodes via launch template (prevents SSRF-based metadata attacks)
- GitHub OIDC authentication - no long-lived AWS access keys in any secret store
- ECR scan on push - vulnerability scanning for container images
- Nodes in private subnets - no public IP addresses
- SSM access - no SSH keys required

---

## Quick Start

### Prerequisites

- AWS account (Free Tier is sufficient for dev - see [cost estimate](docs/cost-estimate.md))
- Terraform >= 1.11.0
- GitHub CLI (`gh`)

### Setup

```bash
# 1. Bootstrap remote state and OIDC provider
cd terraform/bootstrap
cp terraform.tfvars.example terraform.tfvars # edit with your values
terraform init
terraform apply

# 2. Update backend.tf in each environment with bootstrap outputs
# See docs/setup.md for the exact commands

# 3. Deploy dev environment
cd terraform/environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform validate
terraform apply

# 4. Configure GitHub Secrets (Settings -> Secrets and variables -> Actions)
#    DEV_AWS_ROLE_ARN      terraform output github_actions_role_arn
#    AWS_REGION            us-east-1
#    SLACK_WEBHOOK_URL     from your Slack app

# 5. Trigger a manual drift scan
gh workflow run drift-detection.yml --field environment=dev
```

See [docs/setup.md](docs/setup.md) for the complete step-by-step guide.

---

## Simulate Drift (Demo)

```bash
# 1. After deploying dev, manually change node count in AWS:
aws eks update-nodegroup-config \
  --cluster-name terraform-drift-detection-dev \
  --nodegroup-name terraform-drift-detection-dev-nodes \
  --scaling-config desiredSize=2

# 2. Trigger drift detection:
gh workflow run drift-detection.yml --field environment=dev

# 3. Observe:
#    GitHub Issue created: "Drift detected in dev (Sep 28, 2026)"
#    Slack message listing the drifted resources with a Remediate button

# 4. Remediate (restore desired state):
gh workflow run drift-remediation.yml \
  --field environment=dev \
  --field mode=apply \
  --field confirmation=REMEDIATE \
  --field reason="Reverting manual node scaling during demo"

# 5. Observe:
#    GitHub Issue auto-closed
#    Slack: "Drift remediated in dev"
```

Note: The node group has `ignore_changes = [scaling_config[0].desired_size]` because
the Cluster Autoscaler may legitimately change desired_size. Drift is detected for
structural changes, not scaling events.

---

## GitHub Secrets Required

| Secret | Description |
| --- | --- |
| `AWS_REGION` | AWS region (for example, `us-east-1`) |
| `DEV_AWS_ROLE_ARN` | IAM role ARN for dev (`terraform output github_actions_role_arn`) |
| `STAGING_AWS_ROLE_ARN` | IAM role ARN for staging |
| `PROD_AWS_ROLE_ARN` | IAM role ARN for prod |
| `SLACK_WEBHOOK_URL` | Slack incoming webhook URL |
