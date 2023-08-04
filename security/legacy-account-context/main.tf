# --------------------------------------------------
# Create account
# --------------------------------------------------

module "org_account" {
  source        = "../../_sub/security/org-account"
  name          = var.name
  org_role_name = var.org_role_name
  email         = var.email
  parent_id     = var.parent_id
  sleep_after   = 120
}

module "iam_account_alias" {
  source        = "../../_sub/security/iam-account-alias"
  account_alias = module.org_account.name

  providers = {
    aws = aws.workload
  }
}

# --------------------------------------------------
# Account hardening
# --------------------------------------------------
module "hardened-account" {
  count = var.harden ? 1 : 0
  providers = {
    aws.workload   = aws.workload
    aws.workload_2 = aws.workload_2
    aws.sso        = aws.sso
  }
  source = "../../_sub/security/hardened-account"

  harden                          = var.harden
  account_id                      = module.org_account.id
  account_name                    = var.name
  security_bot_lambda_version     = var.security_bot_lambda_version
  security_bot_lambda_s3_bucket   = var.security_bot_lambda_s3_bucket
  monitoring_email                = var.hardened_monitoring_email
  monitoring_slack_channel        = var.hardened_monitoring_slack_channel
  monitoring_slack_token          = var.hardened_monitoring_slack_token
  security_contact_name           = var.hardened_security_contact_name
  security_contact_title          = var.hardened_security_contact_title
  security_contact_email          = var.hardened_security_contact_email
  security_contact_phone_number   = var.hardened_security_contact_phone_number
  sso_support_permission_set_name = var.sso_support_permission_set_name
  sso_support_group_name          = var.sso_support_group_name
}

# --------------------------------------------------
# Certero
# --------------------------------------------------

module "iam_policies" {
  source                            = "../../_sub/security/iam-policies"
  iam_role_trusted_account_root_arn = ["arn:aws:iam::${var.core_account_id}:root"] # Account ID from variable instead of data.aws_caller_identity - seems to get rate-throttled
}

module "iam_role_certero" {
  source               = "../../_sub/security/iam-role"
  role_name            = "CerteroRole"
  role_description     = "Used by CerteroRole to make inventory of AWS resources"
  max_session_duration = 3600
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy_master_account.json
  role_policy_name     = "CerteroEndpoint"
  role_policy_document = module.iam_policies.certero_endpoint

  providers = {
    aws = aws.workload
  }
}

# --------------------------------------------------
# AWS Resource Explorer
# --------------------------------------------------

resource "aws_resourceexplorer2_index" "aggregator" {
  type = "AGGREGATOR"

  provider = aws.workload
}

resource "aws_resourceexplorer2_view" "aggregator_view" {
  name         = "all-resources"
  default_view = true

  included_property {
    name = "tags"
  }

  depends_on = [aws_resourceexplorer2_index.aggregator]
  provider   = aws.workload
}

resource "aws_resourceexplorer2_index" "us-east-1" {
  type     = "LOCAL"
  provider = aws.workload_us-east-1
}

resource "aws_resourceexplorer2_index" "us-east-2" {
  type     = "LOCAL"
  provider = aws.workload_us-east-2
}

resource "aws_resourceexplorer2_index" "us-west-1" {
  type     = "LOCAL"
  provider = aws.workload_us-west-1
}

resource "aws_resourceexplorer2_index" "us-west-2" {
  type     = "LOCAL"
  provider = aws.workload_us-west-2
}

resource "aws_resourceexplorer2_index" "eu-west-1" {
  type     = "LOCAL"
  provider = aws.workload_eu-west-1
}

resource "aws_resourceexplorer2_index" "eu-west-2" {
  type     = "LOCAL"
  provider = aws.workload_eu-west-2
}

resource "aws_resourceexplorer2_index" "eu-west-3" {
  type     = "LOCAL"
  provider = aws.workload_eu-west-3
}
