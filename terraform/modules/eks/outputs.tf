output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.main.name
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
  sensitive   = true
}

output "cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = aws_eks_cluster.main.endpoint
  sensitive   = true
}

output "cluster_certificate_authority_data" {
  description = "Base64-encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.main.certificate_authority[0].data
  sensitive   = true
}

output "cluster_version" {
  description = "Kubernetes version running on the cluster"
  value       = aws_eks_cluster.main.version
}

output "cluster_security_group_id" {
  description = "ID of the EKS cluster security group"
  value       = aws_security_group.cluster.id
}

output "oidc_provider_arn" {
  description = "ARN of the EKS OIDC provider -> used to create IRSA roles for Kubernetes service accounts"
  value       = aws_iam_openid_connect_provider.cluster.arn
}

output "oidc_provider_url" {
  description = "URL of the EKS OIDC provider (without https://)"
  value       = replace(aws_iam_openid_connect_provider.cluster.url, "https://", "")
}

output "node_group_arn" {
  description = "ARN of the EKS managed node group"
  value       = aws_eks_node_group.main.arn
}

output "node_group_status" {
  description = "Current status of the managed node group"
  value       = aws_eks_node_group.main.status
}

output "node_group_resources" {
  description = "Auto Scaling Groups associated with the node group"
  value       = aws_eks_node_group.main.resources
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for EKS secrets encryption"
  value       = aws_kms_key.eks.arn
}

output "launch_template_id" {
  description = "ID of the EC2 launch template used by the node group"
  value       = aws_launch_template.node_group.id
}
