output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr
}

output "private_subnet_ids" {
  description = "IDs of private subnets (EKS node placement)"
  value       = module.vpc.private_subnet_ids
}

output "public_subnet_ids" {
  description = "IDs of public subnets (Load Balancer placement)"
  value       = module.vpc.public_subnet_ids
}

output "nat_gateway_public_ips" {
  description = "Public IPs of NAT Gateways (egress traffic source)"
  value       = module.vpc.nat_gateway_public_ips
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
  sensitive   = true
}

output "eks_cluster_version" {
  description = "Kubernetes version"
  value       = module.eks.cluster_version
}

output "eks_oidc_provider_arn" {
  description = "OIDC provider ARN -> used to create IRSA roles"
  value       = module.eks.oidc_provider_arn
}

output "eks_oidc_provider_url" {
  description = "OIDC provider URL (without https://)"
  value       = module.eks.oidc_provider_url
}

output "eks_node_group_status" {
  description = "Current node group status"
  value       = module.eks.node_group_status
}

output "ecr_repository_urls" {
  description = "Map of ECR repository name -> URL"
  value       = module.ecr.repository_urls
}

output "github_actions_role_arn" {
  description = "GitHub Actions IAM role ARN -> set this as AWS_ROLE_ARN in GitHub Secrets"
  value       = module.iam.github_actions_role_arn
}

output "cluster_role_arn" {
  description = "EKS cluster IAM role ARN"
  value       = module.iam.cluster_role_arn
}

output "node_role_arn" {
  description = "EKS node IAM role ARN"
  value       = module.iam.node_role_arn
}
