# Module to enable Backup through the accounts

# AWS Vault Creation
resource "aws_backup_vault" "vault" {
  count                     = var.deploy_vault ? 1 : 0
  name                      = var.vault_name
  kms_key_arn               = var.kms_key_arn
  access_policy             = data.aws_iam_policy_document.backup_vault_policy.json
  tags                      = merge(var.tags, var.additional_tags)
}

# Backup IAM Role
resource "aws_iam_role" "backup" {
  name               = var.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.backup_role_policy.json
  tags               = merge(var.tags, var.additional_tags)
}

resource "aws_iam_role_policy_attachment" "backup_service_policy" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_iam_role_policy_attachment" "restore_service_policy" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForRestores"
}

# KMS Key for Encryption
resource "aws_kms_key" "backup_key" {
  count                = var.deploy_kms_key ? 1 : 0
  description          = "KMS key for backup encryption"
  enable_key_rotation  = true
  policy               = data.aws_iam_policy_document.backup_key_policy.json
  tags                 = merge(var.tags, var.additional_tags)
}

# Backup Selection
resource "aws_backup_selection" "selection" {
  count           = var.deploy_backup_selection ? 1 : 0
  name            = var.backup_selection_name
  iam_role_arn    = aws_iam_role.backup.arn
  plan_id         = aws_backup_plan.plan.id
  resources       = var.backup_resources
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

data "aws_iam_policy_document" "backup_role_policy" {
  statement {
    actions   = ["sts:AssumeRole"]
    resources = ["*"]

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
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

data "aws_iam_policy_document" "backup_vault_policy" {
  statement {
    sid       = "AllowBackupService"
    actions   = ["backup:*"]
    resources = ["arn:aws:backup:*:*:backup-vault:${aws_backup_vault.vault.name}"]
  }
}

data "aws_caller_identity" "current" {}
