output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_version" {
  description = "Kubernetes version"
  value       = module.eks.cluster_version
}

output "eks_node_group_status" {
  description = "Current node group status"
  value       = module.eks.node_group_status
}

output "github_actions_role_arn" {
  description = "GitHub Actions IAM role ARN -> set this as AWS_ROLE_ARN in GitHub Secrets"
  value       = module.iam.github_actions_role_arn
  sensitive   = true
}
