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

module "iam_identity_center_assignment_IAMRA" {
  source = "../../_sub/security/iam-identity-center-assignment"
  count  = var.sso_IAMRA_permission_set_name != "" && var.sso_IAMRA_group_name != "" ? 1 : 0

  permission_set_name = var.sso_IAMRA_permission_set_name
  group_name          = var.sso_IAMRA_group_name
  aws_account_id      = module.org_account.id

  providers = {
    aws = aws.sso
  }
}

module "iam_identity_center_assignment_netsec_mgmt" {
  source = "../../_sub/security/iam-identity-center-assignment"
  count  = var.sso_netsec_mgmt_permission_set_name != "" && var.sso_netsec_mgmt_group_name != "" ? 1 : 0

  permission_set_name = var.sso_netsec_mgmt_permission_set_name
  group_name          = var.sso_netsec_mgmt_group_name
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
  enable_default_standards        = var.hardened_enable_default_standards
  sso_support_permission_set_name = var.sso_support_permission_set_name
  sso_support_group_name          = var.sso_support_group_name
  kms_primary_key_arn             = var.hardened_kms_primary_key_arn
  kms_replica_key_arn             = var.hardened_kms_replica_key_arn

  depends_on = [
    module.iam_identity_center_assignment,
    module.iam_identity_center_assignment_IAMRA,
    module.cloudtrail_local,
    module.iam_account_alias,
    module.org_account,
    module.iam_policies
  ]
}

# --------------------------------------------------
# AWS Resource Explorer Feature
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
  type = "LOCAL"

  provider = aws.workload_us-east-1
}

resource "aws_resourceexplorer2_index" "us-east-2" {
  type = "LOCAL"

  provider = aws.workload_us-east-2
}
resource "aws_resourceexplorer2_index" "us-west-1" {
  type = "LOCAL"

  provider = aws.workload_us-west-1
}

resource "aws_resourceexplorer2_index" "us-west-2" {
  type = "LOCAL"

  provider = aws.workload_us-west-2
}

resource "aws_resourceexplorer2_index" "eu-west-1" {
  type = "LOCAL"

  provider = aws.workload_2
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
