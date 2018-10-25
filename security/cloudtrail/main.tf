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


data "aws_iam_account_alias" "current" {}

resource "aws_cloudtrail" "cloudtrail" {
  name                  = "${var.cloudtrail_trail_name}"
  s3_bucket_name        = "${var.s3_bucket_name}"
  s3_key_prefix         = "${data.aws_iam_account_alias.current.account_alias}"
  is_multi_region_trail = true
  include_global_service_events = true
  enable_logging = "${var.enable_cloudtrail}"
  enable_log_file_validation = true
}