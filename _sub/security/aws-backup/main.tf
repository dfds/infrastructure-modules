# AWS Vault Creation
resource "aws_backup_vault" "vault" {
  name                      = var.vault_name
  kms_key_arn               = var.deploy_kms_key ? aws_kms_key.this[0].arn : var.kms_key_arn
  tags                      = var.tags
}

# KMS Key for Encryption
resource "aws_kms_key" "this" {
  count                = var.deploy_kms_key ? 1 : 0
  description          = "KMS key for backup encryption"
  enable_key_rotation  = true
  policy               = data.aws_iam_policy_document.backup.json
  tags                 = var.tags
}

data "aws_iam_policy_document" "backup" {
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
resource "aws_backup_plan" "this" {
  name = var.backup_plan_name

  dynamic "advanced_backup_setting" {
    for_each = var.advanced_backup_settings
    content {
      resource_type = var.advanced_backup_setting_resource_type
      backup_options = advanced_backup_setting.value.windows_vss
      }
  }

  tags = var.tags

  dynamic "rule" {
    for_each = var.backup_rules
    content {
      rule_name         = rule.key
      target_vault_name = aws_backup_vault.vault.name
      schedule          = rule.value.schedule
      
      dynamic "lifecycle" {
        for_each = rule.value.lifecycle
        content {
          delete_after = lifecycle.value.delete_after
        }
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
  plan_id         = aws_backup_plan.this[count.index].id
  resources       = var.backup_resources

  
  dynamic "selection_tag" {
    for_each = var.selection_tags
    content {
        type  = selection_tag.value.tag
        key   = selection_tag.value.key
        value = selection_tag.value.value
    }
  }
}

