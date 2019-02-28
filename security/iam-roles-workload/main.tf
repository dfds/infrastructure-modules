provider "aws" {
  version = "~> 1.60.0"
  region  = "${var.aws_region}"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend          "s3"             {}
  required_version = "~> 0.11.7"
}

# Load IAM policy documents from module
module "iam_policies" {
  source                            = "../../_sub/security/iam-policies"
  iam_role_trusted_account_root_arn = "arn:aws:iam::${var.account_id_workload}:root"
}

# Create the role for the master account
resource "aws_iam_role" "workload_role" {
  name               = "${var.iam_role_name}"
  description        = "${var.iam_role_description}"
  assume_role_policy = "${module.iam_policies.trusted_account}"
}

# Create the a role, allowing to create organisation accounts
resource "aws_iam_role_policy" "create_prime_role" {
  name   = "${var.admin_iam_policy_name}"
  role   = "${aws_iam_role.workload_role.id}"
  policy = "${module.iam_policies.admin}"
}
