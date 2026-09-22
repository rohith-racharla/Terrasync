variable "cluster_name" {
  description = "EKS cluster name used as a prefix for all IAM resource names"
  type        = string
}

variable "github_username" {
  description = "GitHub organization or username for the OIDC trust policy sub condition"
  type        = string
}

variable "github_repo" {
  description = "GitHub repository name for the OIDC trust policy sub condition"
  type        = string
}

variable "state_bucket_name" {
  description = "S3 bucket name that holds Terraform state (scoped into GitHub Actions IAM policy)"
  type        = string
}
