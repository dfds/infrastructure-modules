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

resource "aws_cloudtrail" "cloudtrail" {
  name                  = "${var.cloudtrail_trail_name}"
  s3_bucket_name        = "${var.cloudtrail_s3_bucket}"
  s3_key_prefix         = "${var.aws_account_name}"
  is_multi_region_trail = true
  include_global_service_events = true
  enable_logging = "${var.enable_cloudtrail}"
  enable_log_file_validation = true
}