provider "aws" {
  version = "~> 1.60.0"
  region = "${var.aws_region}"
}

provider "aws" {
  version = "~> 1.60.0"
  region = "${var.aws_region}"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = "${module.org_account.org_role_arn}"
  }

  alias = "workload"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend          "s3"             {}
  required_version = "~> 0.11.7"
}

module "org_account" {
  source        = "../../_sub/security/org-account"
  name          = "${var.name}"
  org_role_name = "${var.org_role_name}"
  email         = "${var.email}"
}

module "iam_account_alias" {
  source        = "../../_sub/security/iam-account-alias"
  account_alias = "${module.org_account.name}"

  providers = {
    aws = "aws.workload"
  }
}

module "cloudtrail_s3_central" {
  source           = "../../_sub/storage/s3-cloudtrail-bucket"
  create_s3_bucket = "${var.create_cloudtrail_s3_bucket}"
  s3_bucket        = "${var.cloudtrail_central_s3_bucket}"

  providers = {
    aws = "aws.workload"
  }
}

module "cloudtrail_s3_local" {
  source           = "../../_sub/storage/s3-cloudtrail-bucket"
  create_s3_bucket = "${var.cloudtrail_local_s3_bucket != "" ? 1 : 0}"
  s3_bucket        = "${var.cloudtrail_local_s3_bucket}"

  providers = {
    aws = "aws.workload"
  }
}

module "cloudtrail_local" {
  source     = "../../_sub/security/cloudtrail-config"
  s3_bucket  = "${module.cloudtrail_s3_local.bucket_name}"
  trail_name = "local-audit"

  providers = {
    aws = "aws.workload"
  }
}

resource "null_resource" "apply_tax_settings" {
  provisioner "local-exec" {
    command = "python3 /src/taxregistrations.py ${module.org_account.org_role_arn} ${var.tax_settings_document}"
  }
}
