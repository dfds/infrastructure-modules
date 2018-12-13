provider "aws" {
    # The AWS region in which all resources will be created
    region = "${var.aws_region}"
}

provider "aws" {
    # The AWS region in which all resources will be created
    region = "${var.aws_region}"

    # Assume the Organizational role in Workload account
    assume_role {
      role_arn = "arn:aws:iam::${aws_organizations_account.dfds.id}:role/${var.aws_org_rolename}"
    }

    alias = "workload"
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
}

resource "aws_iam_account_alias" "dfds" {
    #This will change the current account's alias to the one defined in the tfvars file
    account_alias = "${var.aws_account_name}"
    provider      = "aws.workload"
}

module "cloudtrail_s3_central" {
  source = "../../_sub/storage/s3-cloudtrail-bucket"
  create_s3_bucket = "${var.create_cloudtrail_s3_bucket}"
  s3_bucket = "${var.cloudtrail_central_s3_bucket}"

  providers = {
    aws = "aws.workload"
  }  
}

module "cloudtrail_s3_local" {
  source = "../../_sub/storage/s3-cloudtrail-bucket"
  create_s3_bucket = "${var.cloudtrail_local_s3_bucket != "" ? 1 : 0}"
  s3_bucket = "${var.cloudtrail_local_s3_bucket}"

  providers = {
    aws = "aws.workload"
  }  
}

module "cloudtrail_local" {
  source = "../../_sub/security/cloudtrail-config"
  s3_bucket = "${module.cloudtrail_s3_local.bucket_name}"
  trail_name = "local-audit"
  providers = {
    aws = "aws.workload"
  }      
}

resource "null_resource" "apply_tax_settings" {
  provisioner "local-exec" {
    command = "python3 /src/taxregistrations.py ${data.aws_iam_role.aws_org_role.arn} ${var.tax_settings_document}"
  }
}