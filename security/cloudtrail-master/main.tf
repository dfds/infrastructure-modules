provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {}
}

module "cloudtrail_central" {
  source                = "../../_sub/security/cloudtrail-config"
  s3_bucket             = var.cloudtrail_central_s3_bucket
  trail_name            = "org-audit"
  is_organization_trail = true
  deploy                = var.deploy
  create_log_group      = true
  create_kms_key        = true
}
