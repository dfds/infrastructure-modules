data "aws_caller_identity" "current" {}

data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

data "aws_region" "current" {}

data "aws_iam_policy_document" "key_policy" {
  count = var.deploy && var.create_kms_key ? 1 : 0

  statement {
    sid       = "AllowCloudTrailEncryption"
    effect    = "Allow"
    actions   = ["kms:GenerateDataKey*"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${var.trail_name}"]
    }

    condition {
      test     = "StringLike"
      variable = "kms:EncryptionContext:aws:cloudtrail:arn"
      values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
    }
  }

  statement {
    sid       = "AllowCloudTrailDecryption"
    effect    = "Allow"
    actions   = ["kms:Decrypt"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }

  statement {
    sid       = "AllowCloudTrailAccess"
    effect    = "Allow"
    actions   = ["kms:DescribeKey"]
    resources = [aws_kms_key.key[count.index].arn]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = ["arn:aws:cloudtrail:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:trail/${var.trail_name}"]
    }
  }

  statement {
    sid    = "AllowCloudTrailUserAccess"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:GetKeyPolicy",
      "kms:ListResourceTags",
      "kms:GetKeyRotationStatus",
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid    = "AllowCloudTrailAdminAccess"
    effect = "Allow"
    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_session_context.current.issuer_arn]
    }
  }

}

resource "aws_kms_key" "key" {
  count                    = var.deploy && var.create_kms_key ? 1 : 0
  description              = "CloudTrail SSE"
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  is_enabled               = true
  deletion_window_in_days  = 30
  enable_key_rotation      = true
}

resource "aws_kms_key_policy" "policy" {
  count  = var.deploy && var.create_kms_key ? 1 : 0
  key_id = aws_kms_key.key[count.index].key_id
  policy = data.aws_iam_policy_document.key_policy[count.index].json
}

resource "aws_kms_alias" "alias" {
  count         = var.deploy && var.create_kms_key ? 1 : 0
  name          = "alias/cloudtrail/${var.trail_name}"
  target_key_id = aws_kms_key.key[count.index].key_id
}

resource "aws_cloudwatch_log_group" "log_group" {
  count             = var.deploy && var.create_log_group ? 1 : 0
  name              = "/aws/cloudtrail/${var.trail_name}"
  retention_in_days = var.log_group_retention_in_days
}

data "aws_iam_policy_document" "trust" {
  count = var.deploy && var.create_log_group ? 1 : 0

  statement {
    sid     = "AssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudtrail_to_cloudwatch" {
  count = var.deploy && var.create_log_group ? 1 : 0
  name  = "ct-cw-role-${var.trail_name}"

  assume_role_policy = data.aws_iam_policy_document.trust[count.index].json
}

data "aws_iam_policy_document" "logs" {
  count = var.deploy && var.create_log_group ? 1 : 0

  statement {
    sid       = "CreateLogStream"
    actions   = ["logs:CreateLogStream"]
    resources = ["${aws_cloudwatch_log_group.log_group[count.index].arn}:*"]
  }

  statement {
    sid       = "PutLogEvents"
    actions   = ["logs:PutLogEvents"]
    resources = ["${aws_cloudwatch_log_group.log_group[count.index].arn}:*"]
  }
}

resource "aws_iam_role_policy" "cloudtrail_to_cloudwatch" {
  count = var.deploy && var.create_log_group ? 1 : 0
  name  = "ct-cw-policy-${var.trail_name}"
  role  = aws_iam_role.cloudtrail_to_cloudwatch[count.index].id

  policy = data.aws_iam_policy_document.logs[count.index].json
}

# tfsec:ignore:aws-cloudtrail-enable-at-rest-encryption tfsec:ignore:aws-cloudtrail-ensure-cloudwatch-integration
resource "aws_cloudtrail" "cloudtrail" {
  count                         = var.deploy ? 1 : 0
  name                          = var.trail_name
  s3_bucket_name                = var.s3_bucket
  is_multi_region_trail         = true
  is_organization_trail         = var.is_organization_trail
  include_global_service_events = true
  enable_logging                = true
  enable_log_file_validation    = true
  cloud_watch_logs_role_arn     = try(aws_iam_role.cloudtrail_to_cloudwatch[0].arn, null)
  cloud_watch_logs_group_arn    = try("${aws_cloudwatch_log_group.log_group[0].arn}:*", null)
  kms_key_id                    = try(aws_kms_key.key[0].arn, null)
}
