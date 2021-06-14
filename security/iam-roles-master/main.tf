provider "aws" {
  region  = var.aws_region
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}

# Load IAM policy documents from module
module "iam_policies" {
  source                            = "../../_sub/security/iam-policies"
  iam_role_trusted_account_root_arn = [var.iam_role_trusted_account_root_arn]
}

# Create the role for the master account
resource "aws_iam_role" "master_role" {
  name               = var.iam_role_name
  description        = var.iam_role_description
  assume_role_policy = module.iam_policies.trusted_account
}

# Create the a role, allowing to create organisation accounts
resource "aws_iam_role_policy" "create_org_account" {
  name   = var.create_org_account_iam_policy_name
  role   = aws_iam_role.master_role.id
  policy = module.iam_policies.create_org_account
}

