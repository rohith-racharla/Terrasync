terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

locals {
  cluster_name = "${var.project_name}-${var.environment}"
  name_prefix  = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# IAM -> Cluster, Node, and GitHub Actions roles
module "iam" {
  source = "../../modules/iam"

  cluster_name      = local.cluster_name
  github_username   = var.github_username
  github_repo       = var.github_repo
  state_bucket_name = var.state_bucket_name
}

# VPC -> Networking foundation
module "vpc" {
  source = "../../modules/vpc"

  name_prefix             = local.name_prefix
  cluster_name            = local.cluster_name
  vpc_cidr                = var.vpc_cidr
  availability_zones      = var.availability_zones
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidrs    = var.private_subnet_cidrs
  single_nat_gateway      = var.single_nat_gateway
  enable_flow_logs        = var.enable_flow_logs
  flow_log_retention_days = var.flow_log_retention_days
}

# EKS -> Kubernetes cluster
module "eks" {
  source = "../../modules/eks"

  cluster_name                 = local.cluster_name
  cluster_version              = var.cluster_version
  vpc_id                       = module.vpc.vpc_id
  subnet_ids                   = module.vpc.private_subnet_ids
  control_plane_subnet_ids     = module.vpc.private_subnet_ids
  cluster_role_arn             = module.iam.cluster_role_arn
  node_role_arn                = module.iam.node_role_arn
  node_instance_types          = var.node_instance_types
  node_desired_size            = var.node_desired_size
  node_min_size                = var.node_min_size
  node_max_size                = var.node_max_size
  node_disk_size               = var.node_disk_size
  endpoint_private_access      = var.endpoint_private_access
  endpoint_public_access       = var.endpoint_public_access
  endpoint_public_access_cidrs = var.endpoint_public_access_cidrs
  cluster_log_retention_days   = var.cluster_log_retention_days

  tags = local.common_tags
}

# ECR -> container registries
module "ecr" {
  source = "../../modules/ecr"

  name_prefix              = "${var.project_name}/${var.environment}"
  repository_names         = var.ecr_repository_names
  create_repository_policy = true
  node_role_arn            = module.iam.node_role_arn
}
