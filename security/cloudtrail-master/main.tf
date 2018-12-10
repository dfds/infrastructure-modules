provider "aws" {
    # The AWS region in which all resources will be created
    region = "${var.aws_region}"

    version = "~> 1.40"
}

terraform {
    # The configuration for this backend will be filled in by Terragrunt
    backend "s3" {}
    required_version = "~> 0.11.7"
}

module "cloudtrail_central" {
  source = "../../_sub/security/cloudtrail-config"
  s3_bucket = "${var.cloudtrail_central_s3_bucket}"
  trail_name = "org-audit"
  is_organization_trail = true
}