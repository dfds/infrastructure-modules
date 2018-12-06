provider "aws" {
    # The AWS region in which all resources will be created
    region = "${var.aws_region}"
}

provider "aws" {
    # The AWS region in which all resources will be created
    region = "${var.aws_region}"

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
    #Generated an organizational account based on the input from a tfvars file.
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

# resource "aws_cloudtrail" "cloudtrail" {
#   name                  = "${var.cloudtrail_trail_name}"
#   s3_bucket_name        = "${var.cloudtrail_s3_bucket}"
#   s3_key_prefix         = "${var.aws_account_name}"
#   is_multi_region_trail = true
#   include_global_service_events = true
#   enable_logging = true
#   enable_log_file_validation = true
#   provider      = "aws.workload"
# }

module "cloudtrail" {
  source                = "../cloudtrail-config"  
  cloudtrail_trail_name = "${var.cloudtrail_trail_name}"
  cloudtrail_s3_bucket  = "${var.cloudtrail_s3_bucket}"
  aws_account_name      = "${var.aws_account_name}"
  providers = {
    aws = "aws.workload"
  }
}

resource "null_resource" "apply_tax_settings" {
  provisioner "local-exec" {
    command = "python3 /src/taxregistrations.py ${data.aws_iam_role.aws_org_role.arn} ${var.tax_settings_document}"
  }
}