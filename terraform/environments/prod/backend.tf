terraform {
  backend "s3" {
    bucket       = "terraform-drift-detection-tfstate"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    profile      = "terrasync"
    use_lockfile = true
    encrypt      = true
  }
}
