# Hardened account settings

data "aws_region" "workload" {
  count = var.harden ? 1 : 0

  provider = aws.workload
}

resource "aws_securityhub_account" "workload" {
  count                    = var.harden ? 1 : 0
  enable_default_standards = var.enable_default_standards
  provider                 = aws.workload
}

resource "aws_securityhub_standards_subscription" "cis_1_2" {
  count         = var.harden ? 1 : 0
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
  provider      = aws.workload
  depends_on    = [aws_securityhub_account.workload]
}

resource "aws_securityhub_standards_subscription" "cis_1_4" {
  count         = var.harden ? 1 : 0
  standards_arn = "arn:aws:securityhub:${data.aws_region.workload[0].region}::standards/cis-aws-foundations-benchmark/v/1.4.0"
  provider      = aws.workload
  depends_on    = [aws_securityhub_account.workload]
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

resource "aws_sns_topic" "guard_duty_findings_2" {
  count = var.harden ? 1 : 0
  name  = "guard-duty-finding-alarms"

  provider = aws.workload_2
}

resource "aws_sns_topic_subscription" "guard_duty_findings" {
  count     = var.harden && var.monitoring_email != null ? 1 : 0
  topic_arn = aws_sns_topic.guard_duty_findings[count.index].arn
  protocol  = "email"
  endpoint  = var.monitoring_email

  provider = aws.workload
}

resource "aws_sns_topic_subscription" "guard_duty_findings_2" {
  count     = var.harden && var.monitoring_email != null ? 1 : 0
  topic_arn = aws_sns_topic.guard_duty_findings_2[count.index].arn
  protocol  = "email"
  endpoint  = var.monitoring_email

  provider = aws.workload_2
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
      aws_sns_topic.guard_duty_findings[count.index].arn
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
      aws_sns_topic.guard_duty_findings[count.index].arn
    ]
  }
}


data "aws_iam_policy_document" "sns_guard_duty_findings_access_2" {
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
      aws_sns_topic.guard_duty_findings_2[count.index].arn
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
      aws_sns_topic.guard_duty_findings_2[count.index].arn
    ]
  }
}

resource "aws_sns_topic_policy" "guard_duty_findings" {
  count    = var.harden ? 1 : 0
  arn      = aws_sns_topic.guard_duty_findings[count.index].arn
  policy   = data.aws_iam_policy_document.sns_guard_duty_findings_access[count.index].json
  provider = aws.workload
}

resource "aws_sns_topic_policy" "guard_duty_findings_2" {
  count    = var.harden ? 1 : 0
  arn      = aws_sns_topic.guard_duty_findings_2[count.index].arn
  policy   = data.aws_iam_policy_document.sns_guard_duty_findings_access_2[count.index].json
  provider = aws.workload_2
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
  arn      = aws_sns_topic.guard_duty_findings_2[count.index].arn
  provider = aws.workload_2
}

module "security-bot" {
  source                              = "../../../_sub/security/security-bot"
  deploy                              = var.harden && var.monitoring_slack_channel != null && var.monitoring_slack_token != null
  name                                = "security-bot"
  account_name                        = var.account_name
  lambda_version                      = var.security_bot_lambda_version
  lambda_s3_bucket                    = var.security_bot_lambda_s3_bucket
  slack_token                         = var.monitoring_slack_token
  slack_channel                       = var.monitoring_slack_channel
  sns_topic_arn_compliance_changes    = try(aws_sns_topic.compliance_changes[0].arn, null)
  sns_topic_arn_guard_duty_findings   = try(aws_sns_topic.guard_duty_findings[0].arn, null)
  sns_topic_arn_guard_duty_findings_2 = try(aws_sns_topic.guard_duty_findings_2[0].arn, null)

  providers = {
    aws            = aws.workload
    aws.workload   = aws.workload
    aws.workload_2 = aws.workload_2
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

resource "aws_ebs_default_kms_key" "default" {
  count    = var.harden && var.kms_primary_key_arn != null ? 1 : 0
  key_arn  = var.kms_primary_key_arn
  provider = aws.workload
}

resource "aws_ebs_default_kms_key" "default_2" {
  count    = var.harden && var.kms_replica_key_arn != null ? 1 : 0
  key_arn  = var.kms_replica_key_arn
  provider = aws.workload_2
}

resource "aws_kms_grant" "allow_autoscaling_role_use_of_kms_key" {
  count             = var.harden && var.kms_replica_key_arn != null ? 1 : 0
  grantee_principal = "arn:aws:iam::${var.account_id}:role/aws-service-role/autoscaling.amazonaws.com/AWSServiceRoleForAutoScaling"
  key_id            = var.kms_replica_key_arn
  operations        = ["Encrypt", "Decrypt", "ReEncryptFrom", "ReEncryptTo", "GenerateDataKey", "GenerateDataKeyWithoutPlaintext", "DescribeKey", "CreateGrant"]
  name              = "Allow_AWSServiceRoleForAutoScaling_use_of_KMS_key"

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


