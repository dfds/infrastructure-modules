module "iam_policies" {
  source                            = "../../_sub/security/iam-policies"
  iam_role_trusted_account_root_arn = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
}

module "org_account" {
  source        = "../../_sub/security/org-account"
  name          = var.name
  org_role_name = var.org_role_name
  email         = var.email
  parent_id     = var.parent_id
}

module "iam_account_alias" {
  source        = "../../_sub/security/iam-account-alias"
  account_alias = module.org_account.name

  providers = {
    aws = aws.workload
  }
}

module "cloudtrail_s3_local" {
  source           = "../../_sub/storage/s3-cloudtrail-bucket"
  create_s3_bucket = var.cloudtrail_local_s3_bucket != "" ? true : false
  s3_bucket        = var.cloudtrail_local_s3_bucket

  providers = {
    aws = aws.workload
  }
}

module "cloudtrail_local" {
  source     = "../../_sub/security/cloudtrail-config"
  deploy     = var.cloudtrail_local_s3_bucket != "" ? true : false
  s3_bucket  = module.cloudtrail_s3_local.bucket_name
  trail_name = "local-audit"

  providers = {
    aws = aws.workload
  }
}

module "iam_identity_center_assignment" {
  source = "../../_sub/security/iam-identity-center-assignment"

  permission_set_name = var.sso_admin_permission_set_name
  group_name          = var.sso_admin_group_name
  aws_account_id      = module.org_account.id

  providers = {
    aws = aws.sso
  }
}

resource "aws_iam_role" "prime" {
  name                 = var.prime_role_name
  description          = "Admin role to be assumed by Prime"
  assume_role_policy   = module.iam_policies.trusted_account
  max_session_duration = var.prime_role_max_session_duration
  provider             = aws.workload
}

# Create the a Prime Admin role in the Workload account
resource "aws_iam_role_policy" "prime-admin" {
  name     = "Admin"
  role     = aws_iam_role.prime.id
  policy   = module.iam_policies.admin
  provider = aws.workload
}

module "iam_role_certero" {
  source               = "../../_sub/security/iam-role"
  role_name            = "CerteroRole"
  role_description     = ""
  max_session_duration = 3600
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy_master_account.json
  role_policy_name     = "CerteroEndpoint"
  role_policy_document = module.iam_policies.certero_endpoint

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
