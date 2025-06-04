data "aws_caller_identity" "current" {}

locals {
  key_admin_arns = concat(["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"], var.key_admin_arns)
}

# trunk-ignore(checkov/CKV_AWS_109)
# trunk-ignore(checkov/CKV_AWS_111)
# trunk-ignore(checkov/CKV_AWS_356)
data "aws_iam_policy_document" "this" {
  statement {
    sid       = "Enable IAM User Permissions"
    effect    = "Allow"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
  statement {
    sid    = "Allow key administration"
    effect = "Allow"
    actions = [
      "kms:ReplicateKey",
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
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = local.key_admin_arns
    }
  }
  statement {
    sid    = "Allow key usage"
    effect = "Allow"
    actions = [
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant"
    ]
    resources = ["*"]
    dynamic "principals" {
      for_each = var.key_user_arns
      content {
        type        = "AWS"
        identifiers = [principals.value]
      }
    }
  }
}

resource "aws_kms_key" "this" {
  description             = var.description
  key_usage               = var.key_usage
  enable_key_rotation     = var.enable_key_rotation
  multi_region            = var.multi_region
  rotation_period_in_days = var.rotation_period_in_days
  deletion_window_in_days = var.deletion_window_in_days
  policy                  = data.aws_iam_policy_document.this.json
  tags                    = var.tags
  provider                = aws.workload
}

resource "aws_kms_alias" "this" {
  name          = var.key_alias
  target_key_id = aws_kms_key.this.key_id
  provider      = aws.workload
}

resource "aws_kms_replica_key" "this" {
  count                   = var.multi_region ? 1 : 0
  description             = var.description
  deletion_window_in_days = var.deletion_window_in_days
  policy                  = data.aws_iam_policy_document.this.json
  primary_key_arn         = aws_kms_key.this.arn
  provider                = aws.workload_2
}

resource "aws_kms_alias" "replica" {
  count         = var.multi_region ? 1 : 0
  name          = var.key_alias
  target_key_id = aws_kms_replica_key.this[count.index].key_id
  provider      = aws.workload_2
}
