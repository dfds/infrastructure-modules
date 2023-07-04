# AWS Vault Creation
resource "aws_backup_vault" "vault" {
  count                     = var.deploy && var.vault_name != "" ? 1 : 0
  name                      = var.vault_name
  kms_key_arn               = var.deploy_kms_key ? aws_kms_key.backup[0].arn : var.kms_key_arn
  tags                      = var.tags
}

# KMS Key for Encryption
resource "aws_kms_key" "backup" {
  count                = var.deploy && var.deploy_kms_key ? 1 : 0
  description          = "KMS key for backup encryption"
  enable_key_rotation  = true
  policy               = data.aws_iam_policy_document.backup_key_policy.json
  tags                 = var.tags
}

data "aws_iam_policy_document" "backup_key_policy" {
  statement {
    sid       = "Enable IAM User Permissions"
    actions   = ["kms:*"]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }

  statement {
    sid       = "Allow backup service to use the key"
    actions   = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

# Backup Plan
resource "aws_backup_plan" "plan" {
  name = var.backup_plan_name

  dynamic "rule" {
    for_each = var.backup_rules
    content {
      rule_name         = rule.key
      target_vault_name = aws_backup_vault.vault.name
      schedule          = rule.value.schedule
      lifecycle {
        delete_after = rule.value.delete_after
      }
    }
  }
}

data "aws_caller_identity" "current" {}

# Backup Selection
resource "aws_backup_selection" "selection" {
  count           = var.deploy_backup_selection ? 1 : 0
  name            = var.backup_selection_name
  iam_role_arn    = var.iam_role_arn
  plan_id         = aws_backup_plan.plan.id
  resources       = var.backup_resources
}

