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
# AWS Account - Alternate contact
# --------------------------------------------------

module "alternate_contact_security" {
  source = "../../_sub/security/alternate-contact"
  count  = var.email_security != null ? 1 : 0

  contact_type = "SECURITY"
  email        = join("+${var.name}@", split("@", var.email_security))
  phone_number = var.primary_phone_number

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
  sso_support_permission_set_name = var.sso_support_permission_set_name
  sso_support_group_name          = var.sso_support_group_name
  kms_primary_key_arn             = var.hardened_kms_primary_key_arn
  kms_replica_key_arn             = var.hardened_kms_replica_key_arn
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

module "aws_resource_explorer_metrics" {
  source = "../../_sub/monitoring/aws-resource-explorer-metrics"

  allowed_assume_arn = "arn:aws:iam::${var.master_account_id}:role/aws-resource-exporter"

  providers = {
    aws = aws.workload
  }
}

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

# --------------------------------------------------
# AWS Backup
# --------------------------------------------------

locals {
  deploy_kms_key = true
  kms_key_admins = [module.org_account.org_role_arn]
}

resource "aws_iam_role" "backup" {
  provider           = aws.workload
  count              = var.deploy_backup ? 1 : 0
  name               = "backup-role"
  assume_role_policy = data.aws_iam_policy_document.backup_trust.json
}

resource "aws_iam_role_policy_attachment" "backup" {
  provider   = aws.workload
  count      = var.deploy_backup ? 1 : 0
  role       = aws_iam_role.backup[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore" {
  provider   = aws.workload
  count      = var.deploy_backup ? 1 : 0
  role       = aws_iam_role.backup[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

data "aws_iam_policy_document" "backup_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

module "backup_eu_central_1" {
  providers = {
    aws = aws.workload
  }
  count  = var.deploy_backup ? 1 : 0
  source = "../../_sub/security/aws-backup"

  settings_resource_type_opt_in_preference = var.aws_backup_settings_resource_type_opt_in_preference
  resource_type_management_preference      = var.aws_backup_resource_type_management_preference

  new_vault_name = var.aws_backup_vault_name_new
  kms_key_admins = local.kms_key_admins
  backup_plans   = var.aws_backup_plans
  iam_role_arn   = aws_iam_role.backup[0].arn
  tags           = var.aws_backup_tags
}

module "backup_eu_west_1" {
  providers = {
    aws = aws.workload_2
  }
  count  = var.deploy_backup ? 1 : 0
  source = "../../_sub/security/aws-backup"

  settings_resource_type_opt_in_preference = var.aws_backup_settings_resource_type_opt_in_preference
  resource_type_management_preference      = var.aws_backup_resource_type_management_preference

  new_vault_name = var.aws_backup_vault_name_new
  kms_key_admins = local.kms_key_admins
  backup_plans   = var.aws_backup_plans
  iam_role_arn   = aws_iam_role.backup[0].arn
  tags           = var.aws_backup_tags
}

# --------------------------------------------------
# IAM role for Grafana Cloud Cloudwatch integration
# --------------------------------------------------

module "grafana_cloud_cloudwatch_integration" {
  count    = var.grafana_cloud_cloudwatch_integration_iam_role != null ? 1 : 0
  source   = "../../_sub/security/grafana-cloud-cloudwatch-integration"
  iam_role = var.grafana_cloud_cloudwatch_integration_iam_role

  providers = {
    aws = aws.workload
  }
}

# --------------------------------------------------
# Steampipe
# --------------------------------------------------

module "steampipe-audit" {
  source = "../../_sub/security/steampipe-audit"

  allowed_account_id          = var.security_account_id
  allowed_principal_role_name = var.steampipe_audit_role_name

  providers = {
    aws = aws.workload
  }
}
