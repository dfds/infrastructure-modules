provider "aws" {
  region  = var.aws_region
  version = "~> 2.43"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}

module "cloudtrail_central" {
  source                = "../../_sub/security/cloudtrail-config"
  s3_bucket             = var.cloudtrail_central_s3_bucket
  trail_name            = "org-audit"
  is_organization_trail = true
  deploy                = var.deploy
}