output "cluster_role_arn" {
  description = "ARN of the EKS cluster control plane IAM role"
  value       = aws_iam_role.cluster.arn
}

output "cluster_role_name" {
  description = "Name of the EKS cluster control plane IAM role"
  value       = aws_iam_role.cluster.name
}

output "node_role_arn" {
  description = "ARN of the EKS managed node group IAM role"
  value       = aws_iam_role.node.arn
}

output "node_role_name" {
  description = "Name of the EKS managed node group IAM role"
  value       = aws_iam_role.node.name
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions CI/CD IAM role; configure as AWS_ROLE_ARN in GitHub Secrets"
  value       = aws_iam_role.github_actions.arn
}

output "github_actions_role_name" {
  description = "Name of the GitHub Actions CI/CD IAM role"
  value       = aws_iam_role.github_actions.name
}
