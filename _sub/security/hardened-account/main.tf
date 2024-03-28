# Hardened account settings

data "aws_region" "workload" {
  count = var.harden ? 1 : 0

  provider = aws.workload
}

resource "aws_securityhub_standards_subscription" "cis_1_2" {
  count         = var.harden ? 1 : 0
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"

  provider = aws.workload
}

resource "aws_securityhub_standards_subscription" "cis_1_4" {
  count         = var.harden ? 1 : 0
  standards_arn = "arn:aws:securityhub:${data.aws_region.workload[0].name}::standards/cis-aws-foundations-benchmark/v/1.4.0"

  provider = aws.workload
}

resource "aws_sns_topic" "cis_controls" {
  count = var.harden ? 1 : 0
  name  = "cis-control-alarms"

  provider = aws.workload
}

resource "aws_sns_topic_subscription" "cis_controls" {
  count     = var.harden && var.monitoring_email != null ? 1 : 0
  topic_arn = aws_sns_topic.cis_controls[count.index].arn
  protocol  = "email"
  endpoint  = var.monitoring_email

  provider = aws.workload
}

resource "aws_sns_topic" "compliance_changes" {
  count = var.harden ? 1 : 0
  name  = "compliance-change-alarms"

  provider = aws.workload
}

resource "aws_sns_topic_subscription" "compliance_changes" {
  count     = var.harden && var.monitoring_email != null ? 1 : 0
  topic_arn = aws_sns_topic.compliance_changes[count.index].arn
  protocol  = "email"
  endpoint  = var.monitoring_email

  provider = aws.workload
}

resource "aws_cloudwatch_event_rule" "compliance_changes" {
  count       = var.harden ? 1 : 0
  name_prefix = "compliance-changes"
  description = "Config Rules Compliance Change"

  event_pattern = jsonencode({
    "source" : ["aws.config"],
    "detail-type" : ["Config Rules Compliance Change"],
    "detail" : {
      "configRuleName" : [
        { "prefix" : "access-keys-rotated-conformance-pack" },
        { "prefix" : "iam-user-unused-credentials-check-conformance-pack" },
        { "prefix" : "securityhub-nacl-no-unrestricted-ssh-rdp" },
        { "prefix" : "securityhub-s3-bucket-level-public-access-prohibited" },
        { "prefix" : "securityhub-vpc-flow-logs-enabled" },
        { "prefix" : "securityhub-cmk-backing-key-rotation-enabled" },
        { "prefix" : "securityhub-rds-storage-encrypted" },
        { "prefix" : "securityhub-s3-bucket-server-side-encryption-enabled" },
        { "prefix" : "securityhub-vpc-default-security-group-closed" },
      ]
    }
  })
  provider = aws.workload
}

data "aws_iam_policy_document" "sns_compliance_changes_access" {
  count = var.harden ? 1 : 0

  statement {
    sid    = "Default"
    effect = "Allow"
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [var.account_id]
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.compliance_changes[count.index].arn,
    ]
  }

  statement {
    sid    = "PublishEvents"
    effect = "Allow"
    actions = [
      "SNS:Publish",
    ]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.compliance_changes[count.index].arn,
    ]
  }
}

resource "aws_sns_topic_policy" "compliance_changes" {
  count    = var.harden ? 1 : 0
  arn      = aws_sns_topic.compliance_changes[count.index].arn
  policy   = data.aws_iam_policy_document.sns_compliance_changes_access[count.index].json
  provider = aws.workload
}

resource "aws_cloudwatch_event_target" "compliance_changes" {
  count    = var.harden ? 1 : 0
  rule     = aws_cloudwatch_event_rule.compliance_changes[count.index].name
  arn      = aws_sns_topic.compliance_changes[count.index].arn
  provider = aws.workload
}

resource "aws_sns_topic" "guard_duty_findings" {
  count = var.harden ? 1 : 0
  name  = "guard-duty-finding-alarms"

  provider = aws.workload
}

resource "aws_sns_topic_subscription" "guard_duty_findings" {
  count     = var.harden && var.monitoring_email != null ? 1 : 0
  topic_arn = aws_sns_topic.guard_duty_findings[count.index].arn
  protocol  = "email"
  endpoint  = var.monitoring_email

  provider = aws.workload
}

resource "aws_cloudwatch_event_rule" "guard_duty_findings" {
  count       = var.harden ? 1 : 0
  name_prefix = "guard-duty-findings"
  description = "Guard Duty Findings"

  event_pattern = jsonencode({
    "source" : ["aws.guardduty"],
    "detail-type" : ["GuardDuty Finding"]
  })
  provider = aws.workload
}

resource "aws_cloudwatch_event_rule" "guard_duty_findings_2" {
  count       = var.harden ? 1 : 0
  name_prefix = "guard-duty-findings"
  description = "Guard Duty Findings"

  event_pattern = jsonencode({
    "source" : ["aws.guardduty"],
    "detail-type" : ["GuardDuty Finding"]
  })
  provider = aws.workload_2
}

data "aws_iam_policy_document" "sns_guard_duty_findings_access" {
  count = var.harden ? 1 : 0

  statement {
    sid    = "Default"
    effect = "Allow"
    actions = [
      "SNS:Subscribe",
      "SNS:SetTopicAttributes",
      "SNS:RemovePermission",
      "SNS:Receive",
      "SNS:Publish",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:AddPermission",
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [var.account_id]
    }

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sns_topic.guard_duty_findings[count.index].arn,
    ]
  }

  statement {
    sid    = "PublishEvents"
    effect = "Allow"
    actions = [
      "SNS:Publish",
    ]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.guard_duty_findings[count.index].arn,
    ]
  }
}

resource "aws_sns_topic_policy" "guard_duty_findings" {
  count    = var.harden ? 1 : 0
  arn      = aws_sns_topic.guard_duty_findings[count.index].arn
  policy   = data.aws_iam_policy_document.sns_guard_duty_findings_access[count.index].json
  provider = aws.workload
}

resource "aws_cloudwatch_event_target" "guard_duty_findings" {
  count    = var.harden ? 1 : 0
  rule     = aws_cloudwatch_event_rule.guard_duty_findings[count.index].name
  arn      = aws_sns_topic.guard_duty_findings[count.index].arn
  provider = aws.workload
}

resource "aws_cloudwatch_event_target" "guard_duty_findings_2" {
  count    = var.harden ? 1 : 0
  rule     = aws_cloudwatch_event_rule.guard_duty_findings_2[count.index].name
  arn      = aws_sns_topic.guard_duty_findings[count.index].arn
  provider = aws.workload_2
}

module "cloudtrail_s3_local" {
  source           = "../../../_sub/storage/s3-cloudtrail-bucket"
  create_s3_bucket = var.harden
  s3_bucket        = "cloudtrail-local-${var.account_name}"
  s3_log_bucket    = "cloudtrail-local-log-${var.account_name}"

  providers = {
    aws = aws.workload
  }
}

module "cloudtrail_local" {
  source           = "../../../_sub/security/cloudtrail-config"
  s3_bucket        = module.cloudtrail_s3_local.bucket_name
  deploy           = var.harden
  trail_name       = "cloudtrail-local-${var.account_name}"
  create_log_group = var.harden
  create_kms_key   = var.harden

  providers = {
    aws = aws.workload
  }
}

module "security-bot" {
  source                            = "../../../_sub/security/security-bot"
  deploy                            = var.harden && var.monitoring_slack_channel != null && var.monitoring_slack_token != null
  name                              = "security-bot"
  account_name                      = var.account_name
  lambda_version                    = var.security_bot_lambda_version
  lambda_s3_bucket                  = var.security_bot_lambda_s3_bucket
  slack_token                       = var.monitoring_slack_token
  slack_channel                     = var.monitoring_slack_channel
  cloudwatch_logs_group_name        = module.cloudtrail_local.cloudwatch_logs_group_name
  cloudwatch_logs_group_arn         = module.cloudtrail_local.cloudwatch_logs_group_arn
  sns_topic_arn_cis_controls        = try(aws_sns_topic.cis_controls[0].arn, null)
  sns_topic_arn_compliance_changes  = try(aws_sns_topic.compliance_changes[0].arn, null)
  sns_topic_arn_guard_duty_findings = try(aws_sns_topic.guard_duty_findings[0].arn, null)

  providers = {
    aws = aws.workload
  }
}

module "config_s3_local" {
  source           = "../../../_sub/storage/s3-config-bucket"
  create_s3_bucket = var.harden
  s3_bucket        = "config-local-${var.account_name}"

  providers = {
    aws = aws.workload
  }
}

module "config_local" {
  source            = "../../../_sub/security/config-config"
  deploy            = var.harden
  s3_bucket_name    = module.config_s3_local.bucket_name
  s3_bucket_arn     = module.config_s3_local.bucket_arn
  conformance_packs = ["Operational-Best-Practices-for-CIS-AWS-v1.4-Level2"]

  providers = {
    aws = aws.workload
  }
}

module "config_local_2" {
  source            = "../../../_sub/security/config-config"
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
  name                   = var.security_contact_name
  title                  = var.security_contact_title
  email_address          = join("+${var.account_name}@", split("@", var.security_contact_email))
  phone_number           = var.security_contact_phone_number

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
  source   = "../../../_sub/network/vpc-flow-log"
  log_name = "default-vpc-${aws_default_vpc.default[count.index].id}"
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
  source   = "../../../_sub/network/vpc-flow-log"
  log_name = "default-vpc-${aws_default_vpc.default_2[count.index].id}"
  vpc_id   = aws_default_vpc.default_2[count.index].id

  providers = {
    aws = aws.workload_2
  }
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
  source = "../../../_sub/security/iam-identity-center-assignment"

  permission_set_name = var.sso_support_permission_set_name
  group_name          = var.sso_support_group_name
  aws_account_id      = var.account_id

  providers = {
    aws = aws.sso
  }
}

# --------------------------------------------------
# CloudWatch controls
# --------------------------------------------------
# https://docs.aws.amazon.com/securityhub/latest/userguide/cloudwatch-controls.html

module "cis_control_cloudwatch_1" {
  source                = "../../../_sub/security/cloudtrail-alarm"
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
  source                = "../../../_sub/security/cloudtrail-alarm"
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
  source                = "../../../_sub/security/cloudtrail-alarm"
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
  source                = "../../../_sub/security/cloudtrail-alarm"
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
  source                = "../../../_sub/security/cloudtrail-alarm"
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
  source                = "../../../_sub/security/cloudtrail-alarm"
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
  source                = "../../../_sub/security/cloudtrail-alarm"
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
  source                = "../../../_sub/security/cloudtrail-alarm"
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
  source                = "../../../_sub/security/cloudtrail-alarm"
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
  source                = "../../../_sub/security/cloudtrail-alarm"
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
  source                = "../../../_sub/security/cloudtrail-alarm"
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
  source                = "../../../_sub/security/cloudtrail-alarm"
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
  source                = "../../../_sub/security/cloudtrail-alarm"
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
  source                = "../../../_sub/security/cloudtrail-alarm"
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

