provider "aws" {
  region  = var.aws_region
  version = "~> 3.72.0"
}

provider "aws" {
  version = "~> 3.72.0"
  region  = var.aws_region

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }

  alias = "workload"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}

module "org_account" {
  source        = "../../_sub/security/org-account"
  name          = var.name
  org_role_name = var.org_role_name
  email         = var.email
}

module "iam_account_alias" {
  source        = "../../_sub/security/iam-account-alias"
  account_alias = module.org_account.name

  providers = {
    aws = aws.workload
  }
}

module "cloudtrail_s3_central" {
  source           = "../../_sub/storage/s3-cloudtrail-bucket"
  create_s3_bucket = var.create_cloudtrail_s3_bucket
  s3_bucket        = var.cloudtrail_central_s3_bucket

  providers = {
    aws = aws.workload
  }
}

module "cloudtrail_s3_local" {
  source           = "../../_sub/storage/s3-cloudtrail-bucket"
  create_s3_bucket = var.cloudtrail_local_s3_bucket != "" ? true : false
  s3_bucket        = var.cloudtrail_local_s3_bucket

  providers = {
    aws = aws.workload
  }
}

module "cloudtrail_local" {
  source     = "../../_sub/security/cloudtrail-config"
  s3_bucket  = module.cloudtrail_s3_local.bucket_name
  deploy     = var.cloudtrail_local_s3_bucket != "" ? true : false
  trail_name = "local-audit"

  providers = {
    aws = aws.workload
  }
}
