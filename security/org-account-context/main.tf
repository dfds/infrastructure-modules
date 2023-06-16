# --------------------------------------------------
# Init
# --------------------------------------------------

provider "aws" {
  region = var.aws_region

  # Assume role in Master account
  assume_role {
    role_arn = "arn:aws:iam::${var.master_account_id}:role/${var.prime_role_name}"
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "core" # this provider does not seem to be used?
}

provider "aws" {
  region = var.aws_region
  alias  = "shared"

  # Assume role in Shared account
  assume_role {
    role_arn = "arn:aws:iam::${var.shared_account_id}:role/${var.prime_role_name}"
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "workload"

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region = var.aws_region_2
  alias  = "workload_2"

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region = var.aws_region_sso
  alias  = "sso"

  # Assume role in Master account
  assume_role {
    role_arn = "arn:aws:iam::${var.master_account_id}:role/${var.prime_role_name}"
  }
}

####################################################################################################################
# Following providers are needed to deploy Resource Explorer in all available regions
####################################################################################################################
# EU
provider "aws" {
  region = "eu-west-1"
  alias  = "workload_eu-west-1"

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}
provider "aws" {
  region = "eu-west-2"
  alias  = "workload_eu-west-2"

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}
provider "aws" {
  region = "eu-west-3"
  alias  = "workload_eu-west-3"

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region = "eu-north-1"
  alias  = "workload_eu-north-1"

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

# USA
provider "aws" {
  region = "us-east-1"
  alias  = "workload_us-east-1"

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}
provider "aws" {
  region = "us-east-2"
  alias  = "workload_us-east-2"

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}
provider "aws" {
  region = "us-west-1"
  alias  = "workload_us-west-1"

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}
provider "aws" {
  region = "us-west-2"
  alias  = "workload_us-west-2"

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}
# Asia Pacific
provider "aws" {
  region = "ap-south-1"
  alias  = "workload_ap-south-1"
  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}
provider "aws" {
  region = "ap-northeast-3"
  alias  = "workload_ap-northeast-3"
  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}
provider "aws" {
  region = "ap-northeast-2"
  alias  = "workload_ap-northeast-2"
  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}


provider "aws" {
  region = "ap-southeast-1"
  alias  = "workload_ap-southeast-1"
  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}
provider "aws" {
  region = "ap-southeast-2"
  alias  = "workload_ap-southeast-2"
  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region = "ap-northeast-1"
  alias  = "workload_ap-northeast-1"
  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

# Canada
provider "aws" {
  region = "ca-central-1"
  alias  = "workload_ca-central-1"
  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}
# South America
provider "aws" {
  region = "sa-east-1"
  alias  = "workload_sa-east-1"
  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}
####################################################################################################################


terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}

module "iam_policies" {
  source                            = "../../_sub/security/iam-policies"
  iam_role_trusted_account_root_arn = ["arn:aws:iam::${var.core_account_id}:root"] # Account ID from variable instead of data.aws_caller_identity - seems to get rate-throttled
}

module "iam_policies_shared" {
  source        = "../../_sub/security/iam-policies"
  replace_token = var.capability_root_id
}


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
# IAM roles - Shared
# --------------------------------------------------

module "iam_role_shared" {
  source               = "../../_sub/security/iam-role"
  role_name            = var.capability_root_id
  role_path            = var.shared_role_path
  role_description     = "Namespaced access to resources in shared account, e.g. Parameter Store, CloudWatch Logs etc."
  max_session_duration = 28800 # 8 hours
  assume_role_policy   = data.aws_iam_policy_document.shared_role_cap_acc.json
  role_policy_name     = "NamespacedAccessInSharedAccount"
  role_policy_document = module.iam_policies_shared.capability_access_shared

  providers = {
    aws = aws.shared
  }
}

# --------------------------------------------------
# IAM roles - Workload (capability context)
# --------------------------------------------------

module "iam_role_sso_reader" {
  source               = "../../_sub/security/iam-role"
  role_name            = "sso-reader"
  role_description     = "Reads autogenerated roles created for SSO access"
  max_session_duration = 28800 # 8 hours
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy_selfservice.json
  role_policy_name     = "IamRead"
  role_policy_document = module.iam_policies.ssoreader

  providers = {
    aws = aws.workload
  }
}

module "iam_role_ecr_push" {
  source               = "../../_sub/security/iam-role"
  role_name            = "ecr-push"
  role_description     = ""
  max_session_duration = 3600
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy_self.json
  role_policy_name     = "PushToECR"
  role_policy_document = module.iam_policies.push_to_ecr

  providers = {
    aws = aws.workload
  }
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
# IAM deployment user
# --------------------------------------------------

resource "aws_iam_group" "admin" {
  name     = "Admins"
  provider = aws.workload
}

resource "aws_iam_group_policy" "admin" {
  name     = "Admin"
  group    = aws_iam_group.admin.name
  policy   = module.iam_policies.admin
  provider = aws.workload
}

module "iam_user_deploy" {
  source            = "../../_sub/security/iam-user"
  user_name         = "Deploy"
  group_memberships = [aws_iam_group.admin.name]

  providers = {
    aws = aws.workload
  }
}

# --------------------------------------------------
# IAM OpenID Connect Provider
# --------------------------------------------------

module "aws_iam_oidc_provider" {
  source                          = "../../_sub/security/iam-oidc-provider"
  eks_openid_connect_provider_url = var.oidc_provider_url
  eks_cluster_name                = var.oidc_provider_tag

  providers = {
    aws = aws.workload
  }
}

# --------------------------------------------------
# Account hardening
# --------------------------------------------------

resource "aws_sns_topic" "cis_controls" {
  count = var.harden ? 1 : 0
  name  = "cis-control-alarms"

  provider = aws.workload
}

resource "aws_sns_topic_subscription" "cis_controls" {
  count     = var.harden && var.hardened_monitoring_email != null ? 1 : 0
  topic_arn = aws_sns_topic.cis_controls[count.index].arn
  protocol  = "email"
  endpoint  = var.hardened_monitoring_email

  provider = aws.workload
}

module "cloudtrail_s3_local" {
  source           = "../../_sub/storage/s3-cloudtrail-bucket"
  create_s3_bucket = var.harden
  s3_bucket        = "cloudtrail-local-${var.capability_root_id}"
  s3_log_bucket    = "cloudtrail-local-log-${var.capability_root_id}"

  providers = {
    aws = aws.workload
  }
}

module "cloudtrail_local" {
  source           = "../../_sub/security/cloudtrail-config"
  s3_bucket        = module.cloudtrail_s3_local.bucket_name
  deploy           = var.harden
  trail_name       = "cloudtrail-local-${var.capability_root_id}"
  create_log_group = var.harden
  create_kms_key   = var.harden

  providers = {
    aws = aws.workload
  }
}

module "security-bot" {
  source                    = "../../_sub/security/security-bot"
  deploy                    = var.harden && var.hardened_monitoring_slack_channel != null && var.hardened_monitoring_slack_token != null
  name                      = "security-bot"
  slack_token               = var.hardened_monitoring_slack_token
  slack_channel             = var.hardened_monitoring_slack_channel
  alarm_sns_topic_arn       = try(aws_sns_topic.cis_controls[0].arn, null)
  cloudwatch_logs_group_arn = module.cloudtrail_local.cloudwatch_logs_group_arn
  capability_root_id        = var.capability_root_id

  providers = {
    aws = aws.workload
  }
}

module "config_s3_local" {
  source           = "../../_sub/storage/s3-config-bucket"
  create_s3_bucket = var.harden
  s3_bucket        = "config-local-${var.capability_root_id}"

  providers = {
    aws = aws.workload
  }
}

module "config_local" {
  source            = "../../_sub/security/config-config"
  deploy            = var.harden
  s3_bucket_name    = module.config_s3_local.bucket_name
  s3_bucket_arn     = module.config_s3_local.bucket_arn
  conformance_packs = ["Operational-Best-Practices-for-CIS-AWS-v1.4-Level2"]

  providers = {
    aws = aws.workload
  }
}

module "config_local_2" {
  source            = "../../_sub/security/config-config"
  deploy            = var.harden
  s3_bucket_name    = module.config_s3_local.bucket_name
  s3_bucket_arn     = module.config_s3_local.bucket_arn
  conformance_packs = ["Operational-Best-Practices-for-CIS-AWS-v1.4-Level2"]

  providers = {
    aws = aws.workload_2
  }
}

resource "aws_account_alternate_contact" "security" {
  count                  = var.harden ? 1 : 0
  alternate_contact_type = "SECURITY"
  name                   = var.hardened_security_contact_name
  title                  = var.hardened_security_contact_title
  email_address          = join("+${var.name}@", split("@", var.hardened_security_contact_email))
  phone_number           = var.hardened_security_contact_phone_number

  provider = aws.workload
}

# --------------------------------------------------
# Default VPC flow logging
# --------------------------------------------------

resource "aws_default_vpc" "default" {
  count    = var.harden ? 1 : 0
  provider = aws.workload
}

module "default_vpc_flow_log" {
  count    = var.harden ? 1 : 0
  source   = "../../_sub/network/vpc-flow-log"
  log_name = "default-vpc-${var.aws_region}"
  vpc_id   = aws_default_vpc.default[count.index].id

  providers = {
    aws = aws.workload
  }
}

resource "aws_default_vpc" "default_2" {
  count    = var.harden ? 1 : 0
  provider = aws.workload_2
}

module "default_vpc_flow_log_2" {
  count    = var.harden ? 1 : 0
  source   = "../../_sub/network/vpc-flow-log"
  log_name = "default-vpc-${var.aws_region_2}"
  vpc_id   = aws_default_vpc.default_2[count.index].id

  providers = {
    aws = aws.workload_2
  }
}

# --------------------------------------------------
# Default security groups
# --------------------------------------------------

resource "aws_default_security_group" "default" {
  count    = var.harden ? 1 : 0
  vpc_id   = aws_default_vpc.default[count.index].id
  provider = aws.workload
}

resource "aws_default_security_group" "default_2" {
  count    = var.harden ? 1 : 0
  vpc_id   = aws_default_vpc.default_2[count.index].id
  provider = aws.workload_2
}

# --------------------------------------------------
# EBS encryption by default
# --------------------------------------------------

resource "aws_ebs_encryption_by_default" "default" {
  count    = var.harden ? 1 : 0
  enabled  = true
  provider = aws.workload
}

resource "aws_ebs_encryption_by_default" "default_2" {
  count    = var.harden ? 1 : 0
  enabled  = true
  provider = aws.workload_2
}

# --------------------------------------------------
# Password policy
# --------------------------------------------------

resource "aws_iam_account_password_policy" "hardened" {
  count                          = var.harden ? 1 : 0
  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  password_reuse_prevention      = 24
  max_password_age               = 90

  provider = aws.workload
}

# --------------------------------------------------
# Support role
# --------------------------------------------------

module "iam_identity_center_assignment" {
  count  = var.harden && var.sso_support_permission_set_name != null && var.sso_support_group_name != null ? 1 : 0
  source = "../../_sub/security/iam-identity-center-assignment"

  permission_set_name = var.sso_support_permission_set_name
  group_name          = var.sso_support_group_name
  aws_account_id      = module.org_account.id

  providers = {
    aws = aws.sso
  }
}

# --------------------------------------------------
# CloudWatch controls
# --------------------------------------------------
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html

module "cis_control_cloudwatch_1" {
  source                = "../../_sub/security/cloudtrail-alarm"
  deploy                = var.harden
  logs_group_name       = module.cloudtrail_local.cloudwatch_logs_group_name
  alarm_sns_topic_arn   = var.harden ? aws_sns_topic.cis_controls[0].arn : null
  metric_filter_name    = "RootUsage"
  metric_filter_pattern = "{$.userIdentity.type=\"Root\" && $.userIdentity.invokedBy NOT EXISTS && $.eventType !=\"AwsServiceEvent\"}"
  metric_name           = "RootUsageCount"
  alarm_name            = "cis-control-root-usage"
  alarm_description     = <<EOT
  [CloudWatch.1] A log metric filter and alarm should exist for usage of the "root" user:
  https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-1
EOT

  providers = {
    aws = aws.workload
  }
}

module "cis_control_cloudwatch_2" {
  source                = "../../_sub/security/cloudtrail-alarm"
  deploy                = var.harden
  logs_group_name       = module.cloudtrail_local.cloudwatch_logs_group_name
  alarm_sns_topic_arn   = var.harden ? aws_sns_topic.cis_controls[0].arn : null
  metric_filter_name    = "UnauthorizedApiCalls"
  metric_filter_pattern = "{($.errorCode=\"*UnauthorizedOperation\") || ($.errorCode=\"AccessDenied*\")}"
  metric_name           = "UnauthorizedApiCallsCount"
  alarm_name            = "cis-control-unauthorize-api-calls"
  alarm_description     = <<EOT
  [CloudWatch.2] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for unauthorized API calls.
  https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-2
EOT

  providers = {
    aws = aws.workload
  }
}

module "cis_control_cloudwatch_3" {
  source                = "../../_sub/security/cloudtrail-alarm"
  deploy                = var.harden
  logs_group_name       = module.cloudtrail_local.cloudwatch_logs_group_name
  alarm_sns_topic_arn   = var.harden ? aws_sns_topic.cis_controls[0].arn : null
  metric_filter_name    = "NonMfaSignIn"
  metric_filter_pattern = "{ ($.eventName = \"ConsoleLogin\") && ($.additionalEventData.MFAUsed != \"Yes\") && ($.userIdentity.type = \"IAMUser\") && ($.responseElements.ConsoleLogin = \"Success\") }"
  metric_name           = "NonMfaSignInCount"
  alarm_name            = "cis-control-non-mfa-sign-in"
  alarm_description     = <<EOT
   [CloudWatch.3] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for console logins that are not protected by multi-factor authentication (MFA).
  https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-3
EOT

  providers = {
    aws = aws.workload
  }
}

module "cis_control_cloudwatch_4" {
  source                = "../../_sub/security/cloudtrail-alarm"
  deploy                = var.harden
  logs_group_name       = module.cloudtrail_local.cloudwatch_logs_group_name
  alarm_sns_topic_arn   = var.harden ? aws_sns_topic.cis_controls[0].arn : null
  metric_filter_name    = "IamPolicyChanges"
  metric_filter_pattern = "{($.eventName=DeleteGroupPolicy) || ($.eventName=DeleteRolePolicy) || ($.eventName=DeleteUserPolicy) || ($.eventName=PutGroupPolicy) || ($.eventName=PutRolePolicy) || ($.eventName=PutUserPolicy) || ($.eventName=CreatePolicy) || ($.eventName=DeletePolicy) || ($.eventName=CreatePolicyVersion) || ($.eventName=DeletePolicyVersion) || ($.eventName=AttachRolePolicy) || ($.eventName=DetachRolePolicy) || ($.eventName=AttachUserPolicy) || ($.eventName=DetachUserPolicy) || ($.eventName=AttachGroupPolicy) || ($.eventName=DetachGroupPolicy)}"
  metric_name           = "IamPolicyChangesCount"
  alarm_name            = "cis-control-iam-policy-changes"
  alarm_description     = <<EOT
  [CloudWatch.4] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established changes made to Identity and Access Management (IAM) policies.
  https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-4
EOT

  providers = {
    aws = aws.workload
  }
}

module "cis_control_cloudwatch_5" {
  source                = "../../_sub/security/cloudtrail-alarm"
  deploy                = var.harden
  logs_group_name       = module.cloudtrail_local.cloudwatch_logs_group_name
  alarm_sns_topic_arn   = var.harden ? aws_sns_topic.cis_controls[0].arn : null
  metric_filter_name    = "CloudTrailChanges"
  metric_filter_pattern = "{($.eventName=CreateTrail) || ($.eventName=UpdateTrail) || ($.eventName=DeleteTrail) || ($.eventName=StartLogging) || ($.eventName=StopLogging)}"
  metric_name           = "CloudTrailChangesCount"
  alarm_name            = "cis-control-cloudtrail-changes"
  alarm_description     = <<EOT
  [CloudWatch.5] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for detecting changes to CloudTrail's configurations.
  https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-5
EOT

  providers = {
    aws = aws.workload
  }
}

module "cis_control_cloudwatch_6" {
  source                = "../../_sub/security/cloudtrail-alarm"
  deploy                = var.harden
  logs_group_name       = module.cloudtrail_local.cloudwatch_logs_group_name
  alarm_sns_topic_arn   = var.harden ? aws_sns_topic.cis_controls[0].arn : null
  metric_filter_name    = "FailedConsoleAuthentication"
  metric_filter_pattern = "{($.eventName=ConsoleLogin) && ($.errorMessage=\"Failed authentication\")}"
  metric_name           = "FailedConsoleAuthenticationCount"
  alarm_name            = "cis-control-failed-console-authentication"
  alarm_description     = <<EOT
  [CloudWatch.6] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for failed console authentication attempts.
  https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-6
EOT

  providers = {
    aws = aws.workload
  }
}

module "cis_control_cloudwatch_7" {
  source                = "../../_sub/security/cloudtrail-alarm"
  deploy                = var.harden
  logs_group_name       = module.cloudtrail_local.cloudwatch_logs_group_name
  alarm_sns_topic_arn   = var.harden ? aws_sns_topic.cis_controls[0].arn : null
  metric_filter_name    = "CmkStateChange"
  metric_filter_pattern = "{($.eventSource=kms.amazonaws.com) && (($.eventName=DisableKey) || ($.eventName=ScheduleKeyDeletion))}"
  metric_name           = "CmkStateChangeCount"
  alarm_name            = "cis-control-cmk-state-change"
  alarm_description     = <<EOT
  [CloudWatch.7] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for customer created CMKs which have changed state to disabled or scheduled deletion.
  https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-7
EOT

  providers = {
    aws = aws.workload
  }
}

module "cis_control_cloudwatch_8" {
  source                = "../../_sub/security/cloudtrail-alarm"
  deploy                = var.harden
  logs_group_name       = module.cloudtrail_local.cloudwatch_logs_group_name
  alarm_sns_topic_arn   = var.harden ? aws_sns_topic.cis_controls[0].arn : null
  metric_filter_name    = "S3PolicyChange"
  metric_filter_pattern = "{($.eventSource=s3.amazonaws.com) && (($.eventName=PutBucketAcl) || ($.eventName=PutBucketPolicy) || ($.eventName=PutBucketCors) || ($.eventName=PutBucketLifecycle) || ($.eventName=PutBucketReplication) || ($.eventName=DeleteBucketPolicy) || ($.eventName=DeleteBucketCors) || ($.eventName=DeleteBucketLifecycle) || ($.eventName=DeleteBucketReplication))}"
  metric_name           = "S3PolicyChangeCount"
  alarm_name            = "cis-control-s3-policy-change"
  alarm_description     = <<EOT
  [CloudWatch.8] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for changes to S3 bucket policies.
  https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-8
EOT

  providers = {
    aws = aws.workload
  }
}

module "cis_control_cloudwatch_9" {
  source                = "../../_sub/security/cloudtrail-alarm"
  deploy                = var.harden
  logs_group_name       = module.cloudtrail_local.cloudwatch_logs_group_name
  alarm_sns_topic_arn   = var.harden ? aws_sns_topic.cis_controls[0].arn : null
  metric_filter_name    = "AwsConfigChange"
  metric_filter_pattern = "{($.eventSource=config.amazonaws.com) && (($.eventName=StopConfigurationRecorder) || ($.eventName=DeleteDeliveryChannel) || ($.eventName=PutDeliveryChannel) || ($.eventName=PutConfigurationRecorder))}"
  metric_name           = "AwsConfigChangeCount"
  alarm_name            = "cis-control-aws-config-change"
  alarm_description     = <<EOT
  [CloudWatch.9] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is recommended that a metric filter and alarm be established for detecting changes to CloudTrail's configurations.
  https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-9
EOT

  providers = {
    aws = aws.workload
  }
}

module "cis_control_cloudwatch_10" {
  source                = "../../_sub/security/cloudtrail-alarm"
  deploy                = var.harden
  logs_group_name       = module.cloudtrail_local.cloudwatch_logs_group_name
  alarm_sns_topic_arn   = var.harden ? aws_sns_topic.cis_controls[0].arn : null
  metric_filter_name    = "SecurityGroupChange"
  metric_filter_pattern = "{($.eventName=AuthorizeSecurityGroupIngress) || ($.eventName=AuthorizeSecurityGroupEgress) || ($.eventName=RevokeSecurityGroupIngress) || ($.eventName=RevokeSecurityGroupEgress) || ($.eventName=CreateSecurityGroup) || ($.eventName=DeleteSecurityGroup)}"
  metric_name           = "SecurityGroupChangeCount"
  alarm_name            = "cis-control-security-group-change"
  alarm_description     = <<EOT
  [CloudWatch.10] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. Security Groups are a stateful packet filter that controls ingress and egress traffic within a VPC. It is recommended that a metric filter and alarm be established changes to Security Groups.
  https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-10
EOT

  providers = {
    aws = aws.workload
  }
}

module "cis_control_cloudwatch_11" {
  source                = "../../_sub/security/cloudtrail-alarm"
  deploy                = var.harden
  logs_group_name       = module.cloudtrail_local.cloudwatch_logs_group_name
  alarm_sns_topic_arn   = var.harden ? aws_sns_topic.cis_controls[0].arn : null
  metric_filter_name    = "NaclChange"
  metric_filter_pattern = "{($.eventName=CreateNetworkAcl) || ($.eventName=CreateNetworkAclEntry) || ($.eventName=DeleteNetworkAcl) || ($.eventName=DeleteNetworkAclEntry) || ($.eventName=ReplaceNetworkAclEntry) || ($.eventName=ReplaceNetworkAclAssociation)}"
  metric_name           = "NaclChangeCount"
  alarm_name            = "cis-control-nacl-change"
  alarm_description     = <<EOT
  [CloudWatch.11] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. NACLs are used as a stateless packet filter to control ingress and egress traffic for subnets within a VPC. It is recommended that a metric filter and alarm be established for changes made to NACLs.
  https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-11
EOT

  providers = {
    aws = aws.workload
  }
}

module "cis_control_cloudwatch_12" {
  source                = "../../_sub/security/cloudtrail-alarm"
  deploy                = var.harden
  logs_group_name       = module.cloudtrail_local.cloudwatch_logs_group_name
  alarm_sns_topic_arn   = var.harden ? aws_sns_topic.cis_controls[0].arn : null
  metric_filter_name    = "NetworkGatewayChange"
  metric_filter_pattern = "{($.eventName=CreateCustomerGateway) || ($.eventName=DeleteCustomerGateway) || ($.eventName=AttachInternetGateway) || ($.eventName=CreateInternetGateway) || ($.eventName=DeleteInternetGateway) || ($.eventName=DetachInternetGateway)}"
  metric_name           = "NetworkGatewayChangeCount"
  alarm_name            = "cis-control-network-gateway-change"
  alarm_description     = <<EOT
  [CloudWatch.12] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. Network gateways are required to send/receive traffic to a destination outside of a VPC. It is recommended that a metric filter and alarm be established for changes to network gateways.
  https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-12
EOT

  providers = {
    aws = aws.workload
  }
}

module "cis_control_cloudwatch_13" {
  source                = "../../_sub/security/cloudtrail-alarm"
  deploy                = var.harden
  logs_group_name       = module.cloudtrail_local.cloudwatch_logs_group_name
  alarm_sns_topic_arn   = var.harden ? aws_sns_topic.cis_controls[0].arn : null
  metric_filter_name    = "RouteTableChange"
  metric_filter_pattern = "{($.eventSource=ec2.amazonaws.com) && (($.eventName=CreateRoute) || ($.eventName=CreateRouteTable) || ($.eventName=ReplaceRoute) || ($.eventName=ReplaceRouteTableAssociation) || ($.eventName=DeleteRouteTable) || ($.eventName=DeleteRoute) || ($.eventName=DisassociateRouteTable))}"
  metric_name           = "RouteTableChangeCount"
  alarm_name            = "cis-control-route-table-change"
  alarm_description     = <<EOT
  [CloudWatch.13] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. Routing tables are used to route network traffic between subnets and to network gateways. It is recommended that a metric filter and alarm be established for changes to route tables.
  https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-13
EOT

  providers = {
    aws = aws.workload
  }
}

module "cis_control_cloudwatch_14" {
  source                = "../../_sub/security/cloudtrail-alarm"
  deploy                = var.harden
  logs_group_name       = module.cloudtrail_local.cloudwatch_logs_group_name
  alarm_sns_topic_arn   = var.harden ? aws_sns_topic.cis_controls[0].arn : null
  metric_filter_name    = "VpcChange"
  metric_filter_pattern = "{($.eventName=CreateVpc) || ($.eventName=DeleteVpc) || ($.eventName=ModifyVpcAttribute) || ($.eventName=AcceptVpcPeeringConnection) || ($.eventName=CreateVpcPeeringConnection) || ($.eventName=DeleteVpcPeeringConnection) || ($.eventName=RejectVpcPeeringConnection) || ($.eventName=AttachClassicLinkVpc) || ($.eventName=DetachClassicLinkVpc) || ($.eventName=DisableVpcClassicLink) || ($.eventName=EnableVpcClassicLink)}"
  metric_name           = "VpcChangeCount"
  alarm_name            = "cis-control-vpc-change"
  alarm_description     = <<EOT
  [CloudWatch.14] Real-time monitoring of API calls can be achieved by directing CloudTrail Logs to CloudWatch Logs and establishing corresponding metric filters and alarms. It is possible to have more than 1 VPC within an account, in addition it is also possible to create a peer connection between 2 VPCs enabling network traffic to route between VPCs. It is recommended that a metric filter and alarm be established for changes made to VPCs.
  https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html#cloudwatch-14
EOT

  providers = {
    aws = aws.workload
  }
}

# --------------------------------------------------
# aws_context_account_created event
# --------------------------------------------------

locals {
  # account_created_payload = <<EOF
  # {"contextId":"${var.context_id}","accountId":"${module.org_account.id}","roleArn":"${module.iam_role_capability.arn}","roleEmail":"${module.org_account.email}","capabilityRootId":"${var.capability_root_id}","capabilityName":"${var.capability_name}","contextName":"${var.context_name}","capabilityId":"${var.capability_id}"}EOF
  account_created_payload_map = {
    "contextId"        = var.context_id
    "accountId"        = module.org_account.id
    "roleEmail"        = module.org_account.email
    "capabilityRootId" = var.capability_root_id
    "capabilityName"   = var.capability_name
    "contextName"      = var.context_name
    "capabilityId"     = var.capability_id
  }

  account_created_payload_json = jsonencode(local.account_created_payload_map)
}

module "kafka_produce_account_created" {
  source          = "../../_sub/misc/kafka-message"
  publish         = var.publish_message
  event_name      = "aws_context_account_created"
  message_version = "1"
  correlation_id  = var.correlation_id
  sender          = "org-account-context created by terraform"
  payload         = local.account_created_payload_json
  key             = var.capability_id
  broker          = var.kafka_broker
  topic           = "build.selfservice.events.capabilities"
  username        = var.kafka_username
  password        = var.kafka_password
}

# --------------------------------------------------
# AWS Resource Explorer Feature
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

resource "aws_resourceexplorer2_index" "ap-south-1" {
  type = "LOCAL"

  provider = aws.workload_ap-south-1
}

resource "aws_resourceexplorer2_index" "ap-northeast-3" {
  type = "LOCAL"

  provider = aws.workload_ap-northeast-3
}

resource "aws_resourceexplorer2_index" "ap-northeast-2" {
  type = "LOCAL"

  provider = aws.workload_ap-northeast-2
}

resource "aws_resourceexplorer2_index" "ap-southeast-1" {
  type = "LOCAL"

  provider = aws.workload_ap-southeast-1
}
resource "aws_resourceexplorer2_index" "ap-southeast-2" {
  type = "LOCAL"

  provider = aws.workload_ap-southeast-2
}
resource "aws_resourceexplorer2_index" "ap-northeast-1" {
  type = "LOCAL"

  provider = aws.workload_ap-northeast-1
}

resource "aws_resourceexplorer2_index" "ca-central-1" {
  type = "LOCAL"

  provider = aws.workload_ca-central-1
}

resource "aws_resourceexplorer2_index" "eu-west-1" {
  type = "LOCAL"

  provider = aws.workload_eu-west-1
}
resource "aws_resourceexplorer2_index" "eu-west-2" {
  type = "LOCAL"

  provider = aws.workload_eu-west-2
}

resource "aws_resourceexplorer2_index" "eu-west-3" {
  type = "LOCAL"

  provider = aws.workload_eu-west-3
}

resource "aws_resourceexplorer2_index" "eu-north-1" {
  type = "LOCAL"

  provider = aws.workload_eu-north-1
}


resource "aws_resourceexplorer2_index" "sa-east-1" {
  type = "LOCAL"

  provider = aws.workload_sa-east-1
}
