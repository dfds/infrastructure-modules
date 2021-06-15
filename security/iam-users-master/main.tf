provider "aws" {
  region  = var.aws_region
  version = "~> 2.43"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}

# Load IAM policy documents from module
module "iam_policies" {
  source                 = "../../_sub/security/iam-policies"
  core_account_role_arns = var.core_account_role_arns
}

# Create the user for the master account
resource "aws_iam_user" "master_user" {
  name = var.iam_user_name
}

resource "aws_iam_access_key" "master_user_key" {
  user = aws_iam_user.master_user.name
}

# 
resource "aws_iam_user_policy" "assume_noncore_accounts" {
  name   = var.assume_noncore_accounts_iam_policy_name
  user   = aws_iam_user.master_user.id
  policy = module.iam_policies.assume_noncore_accounts
}

