output "repository_urls" {
  description = "Map of repository name -> ECR URL (use for docker push/pull)"
  value       = { for k, v in aws_ecr_repository.repos : k => v.repository_url }
}

output "repository_arns" {
  description = "Map of repository name -> ECR ARN"
  value       = { for k, v in aws_ecr_repository.repos : k => v.arn }
}

output "registry_id" {
  description = "AWS Account ID (ECR registry ID)"
  value       = data.aws_caller_identity.current.account_id
}

output "registry_url" {
  description = "ECR registry URL (without repository name)"
  value       = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${split(".", values(aws_ecr_repository.repos)[0].repository_url)[1]}.amazonaws.com"
}
