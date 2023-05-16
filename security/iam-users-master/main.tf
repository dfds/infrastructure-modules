provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
  }
}

# Load IAM policy documents from module
module "iam_policies" {
  source                 = "../../_sub/security/iam-policies"
  core_account_role_arns = var.core_account_role_arns
}

# Create the user for the master account
# tfsec:ignore:aws-iam-no-user-attached-policies
resource "aws_iam_user" "master_user" {
  name = var.iam_user_name
}

resource "aws_iam_user_policy" "assume_noncore_accounts" {
  name   = var.assume_noncore_accounts_iam_policy_name
  user   = aws_iam_user.master_user.id
  policy = module.iam_policies.assume_noncore_accounts
}

# ------------------------------------------------------------------------------
# Certero
# ------------------------------------------------------------------------------

# tfsec:ignore:aws-iam-no-user-attached-policies
resource "aws_iam_user" "certero_endpoint_user" {
  name = "CerteroEndpointUser"
}

resource "aws_iam_user_policy" "certero_endpoint" {
  name   = "CerteroEndpoint"
  user   = aws_iam_user.certero_endpoint_user.name
  policy = module.iam_policies.certero_endpoint_for_master_account
}
