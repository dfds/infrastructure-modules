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

resource "aws_cognito_user_pool" "pool" {
  name = "${var.user_pool_name}"
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.user_pool_domain_name}"
  user_pool_id = "${aws_cognito_user_pool.pool.id}"
}

