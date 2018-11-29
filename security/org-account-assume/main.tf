provider "aws" {
    # The AWS region in which all resources will be created
    region = "${var.aws_region}"

    # Assume role in Master account
    assume_role {
        role_arn = "${var.assume_role_arn}"
    }

}

provider "aws" {
    region = "${var.aws_region}"
    alias = "core"
}

provider "aws" {
    # The AWS region in which all resources will be created
    region = "${var.aws_region}"

    # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account 
    access_key = "${var.access_key_master}"
    secret_key = "${var.secret_key_master}"

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

module "iam_policies" {
    source = "../../_sub/security/iam-policies"
    iam_role_trusted_account_root_arn = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
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

resource "aws_cloudtrail" "cloudtrail" {
  name                  = "${var.cloudtrail_trail_name}"
  s3_bucket_name        = "${var.cloudtrail_s3_bucket}"
  s3_key_prefix         = "${var.aws_account_name}"
  is_multi_region_trail = true
  include_global_service_events = true
  enable_logging = true
  enable_log_file_validation = true
  provider      = "aws.workload"
}

resource "aws_iam_role" "prime" {
    name = "${var.prime_rolename}"
    description = "Admin role to be assumed by Prime"
    assume_role_policy = "${module.iam_policies.trusted_account}"
    provider      = "aws.workload"
}

# Create the a role, allowing to create organisation accounts
resource "aws_iam_role_policy" "prime-admin" {
    name = "Admin"
    role = "${aws_iam_role.prime.id}"
    policy = "${module.iam_policies.admin}"
    provider      = "aws.workload"
}
