output "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state"
  value       = aws_s3_bucket.terraform_state.bucket
}

output "state_bucket_arn" {
  description = "ARN of the S3 state bucket"
  value       = aws_s3_bucket.terraform_state.arn
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider. This is referenced by each environment's IAM module"
  value       = aws_iam_openid_connect_provider.github.arn
}
