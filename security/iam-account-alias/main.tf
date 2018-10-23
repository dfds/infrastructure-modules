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

resource "aws_iam_account_alias" "dfds" {
    #This will change the current account's alias to the one defined in the tfvars file
    account_alias = "${var.aws_account_name}"
    provider      = "aws"
}