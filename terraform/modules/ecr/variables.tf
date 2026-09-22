variable "name_prefix" {
  description = "Prefix for ECR repository names (e.g., drift-detection/dev)"
  type        = string
}

variable "repository_names" {
  description = "List of repository names to create under the name_prefix"
  type        = list(string)
  default     = ["frontend", "backend"]
}

variable "image_tag_mutability" {
  description = "Image tag mutability: IMMUTABLE (recommended) prevents tag overwrites"
  type        = string
  default     = "IMMUTABLE"

  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "image_tag_mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "max_tagged_images" {
  description = "Maximum number of tagged images to retain (older images are expired)"
  type        = number
  default     = 10
}

variable "untagged_expiry_days" {
  description = "Days after which untagged images are automatically expired"
  type        = number
  default     = 1
}

variable "create_repository_policy" {
  description = "Whether to create an ECR repository policy granting the node role pull access. Set to false only if no node_role_arn is available yet."
  type        = bool
  default     = true
}

variable "node_role_arn" {
  description = "ARN of the EKS node IAM role - granted ECR pull permissions. Required when create_repository_policy is true."
  type        = string
  default     = ""
}
