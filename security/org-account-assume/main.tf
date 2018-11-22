provider "aws" {
    # The AWS region in which all resources will be created
    region = "${var.aws_region}"

}

provider "aws" {
    # The AWS region in which all resources will be created
    region = "${var.aws_region}"

    access_key = "${var.access_key_master}"
    secret_key = "${var.secret_key_master}"

    alias = "master"

}

provider "aws" {
    # The AWS region in which all resources will be created
    region = "${var.aws_region}"

    access_key = "${var.access_key_master}"
    secret_key = "${var.secret_key_master}"

    assume_role {
        # role_arn = "arn:aws:iam::454234050858:role/Prime"
        role_arn = "arn:aws:iam::${aws_organizations_account.dfds.id}:role/${var.aws_org_rolename}"
    }

    alias = "child"
}

terraform {
    # The configuration for this backend will be filled in by Terragrunt
    backend "s3" {}
    required_version = "~> 0.11.7"
}

resource "aws_organizations_account" "dfds" {
    #Generate an organizational account based on the input from a tfvars file.
    name                       = "${var.aws_account_name}"
    email                      = "aws.${replace(var.aws_account_name, "dfds-", "")}@${var.email_domain}"
    iam_user_access_to_billing = "ALLOW"
    role_name                  = "${var.aws_org_rolename}"

    provider = "aws.master"
}

resource "aws_s3_bucket" "master" {
    bucket = "dfds-random-master2"
    provider = "aws.master"
}

resource "aws_s3_bucket" "child" {
    bucket = "dfds-random-child2"
    provider = "aws.child"
}
