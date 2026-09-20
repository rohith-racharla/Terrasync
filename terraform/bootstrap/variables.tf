variable "aws_region" {
  description = "AWS region where backend resources are created"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "Which profile to use to call the AWS API"
  type        = string
  default     = "default"
}

variable "project_name" {
  description = "Project name used as a prefix for all bootstrap resources"
  type        = string
  default     = "terraform-drift-detection"
}
