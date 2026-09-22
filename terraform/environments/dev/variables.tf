variable "aws_region" {
  description = "AWS region where this environment is deployed"
  type        = string
}

variable "aws_profile" {
  description = "Which profile to use to call the AWS API"
  type        = string
  default     = "default"
}

variable "project_name" {
  description = "Project name prefix applied to all resource names and tags"
  type        = string
}

variable "environment" {
  description = "Environment name (dev | staging | prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}

variable "github_username" {
  description = "GitHub organization or username -> scopes the OIDC trust policy"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name -> scopes the OIDC trust policy"
  type        = string
}

variable "state_bucket_name" {
  description = "S3 bucket name from bootstrap -> used in GitHub Actions IAM policy"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC (e.g., 10.10.0.0/16 for dev)"
  type        = string
}

variable "availability_zones" {
  description = "Availability zones to use in this region"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets -> one per AZ"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets -> one per AZ"
  type        = list(string)
}

variable "single_nat_gateway" {
  description = "Single NAT Gateway (true=cost saving, false=HA one per AZ)"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Enable VPC Flow Logs to CloudWatch"
  type        = bool
  default     = false
}

variable "flow_log_retention_days" {
  description = "CloudWatch retention period for flow logs (days)"
  type        = number
  default     = 7
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.36"
}

variable "node_instance_types" {
  description = "EC2 instance types for the managed node group"
  type        = list(string)
}

variable "node_desired_size" {
  description = "Desired number of nodes"
  type        = number
}

variable "node_min_size" {
  description = "Minimum number of nodes (autoscaler lower bound)"
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of nodes (autoscaler upper bound)"
  type        = number
}

variable "node_disk_size" {
  description = "Root EBS volume size in GiB per node"
  type        = number
  default     = 20
}

variable "endpoint_private_access" {
  description = "Enable private API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public API server endpoint"
  type        = bool
  default     = true
}

variable "endpoint_public_access_cidrs" {
  description = "IP ranges allowed to hit the public Kubernetes API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cluster_log_retention_days" {
  description = "Retention for EKS control plane logs in CloudWatch (days)"
  type        = number
  default     = 7
}

variable "ecr_repository_names" {
  description = "Names of ECR repositories to create for this environment"
  type        = list(string)
  default     = ["frontend", "backend"]
}
