provider "aws" {
  region = "eu-west-1"
}

# AWS Vault Creation
resource "aws_backup_vault" "vault" {
  name        = var.vault_name
  kms_key_arn = var.deploy_kms_key ? aws_kms_key.this[0].arn : var.kms_key_arn
  tags        = var.tags
}

# KMS Key for Encryption
resource "aws_kms_key" "this" {
  count               = var.deploy_kms_key ? 1 : 0
  description         = "KMS key for backup encryption"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.backup.json
  tags                = var.tags
}

data "aws_iam_policy_document" "backup" {
  statement {
    sid = "Allow access for Key Administrators"
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
      identifiers = var.kms_key_admins
    }
  }
  statement {
    sid = "Allow access through Backup for all principals in the account that are authorized to use Backup Storage"
    actions = [
      "kms:CreateGrant",
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["backup.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}

data "aws_region" "current" {}

# Backup Plan
resource "aws_backup_plan" "this" {
  count = var.backup_plan_name != "" ? 1 : 0
  name  = var.backup_plan_name

  dynamic "rule" {
    for_each = var.backup_rules
    content {
      rule_name                = rule.value.name
      target_vault_name        = aws_backup_vault.vault.name
      schedule                 = lookup(rule.value, "schedule", null)
      enable_continuous_backup = lookup(rule.value, "enable_continous_backup", null)
      start_window             = lookup(rule.value, "start_window", null)
      completion_window        = lookup(rule.value, "completion_window", null)
      recovery_point_tags      = lookup(rule.value, "recovery_point_tags", {})

      dynamic "copy_action" {
        for_each = lookup(rule.value, "copy_action", [])
        content {
          destination_vault_arn = lookup(copy_action.value, "destination_vault_arn", null)
          dynamic "lifecycle" {
            for_each = lookup(copy_action.value, "lifecycle", {})
            content {
              cold_storage_after = lookup(lifecycle.value, "cold_storage_after", 0)
              delete_after       = lookup(lifecycle.value, "delete_after", 30)
            }

          }
        }
      }


      dynamic "lifecycle" {
        for_each = rule.value.lifecycle
        content {
          delete_after = lifecycle.value.delete_after
        }
      }
    }
  }

  tags = var.tags
}


data "aws_caller_identity" "current" {}

# Backup Selection
#resource "aws_backup_selection" "selection" {
#  count           = var.deploy_backup_selection ? 1 : 0
#  name            = var.backup_selection_name
#  iam_role_arn    = var.iam_role_arn
#  plan_id         = aws_backup_plan.this[count.index].id
#  resources       = var.backup_resources


#  dynamic "selection_tag" {
#    for_each = var.selection_tags
#    content {
#        type  = selection_tag.value.tag
#        key   = selection_tag.value.key
#        value = selection_tag.value.value
#    }
#  }
#}

# Backup Selection
resource "aws_backup_selection" "this" {
  for_each      = var.backup_selections
  name          = each.value.name
  iam_role_arn  = var.iam_role_arn
  plan_id       = aws_backup_plan.this[0].id
  resources     = lookup(each.value, "resources", [])
  not_resources = lookup(each.value, "not_resources", [])
  dynamic "condition" {
    for_each = lookup(each.value, "conditions", [])
    content {
      dynamic "string_equals" {
        for_each = lookup(condition.value, "string_equals", [])
        content {
          key   = string_equals.value.key
          value = string_equals.value.value
        }
      }
      dynamic "string_like" {
        for_each = lookup(condition.value, "string_like", [])
        content {
          key   = string_like.value.key
          value = string_like.value.value
        }
      }
      dynamic "string_not_equals" {
        for_each = lookup(condition.value, "string_not_equals", [])
        content {
          key   = string_not_equals.value.key
          value = string_not_equals.value.value
        }
      }
      dynamic "string_not_like" {
        for_each = lookup(condition.value, "string_not_like", [])
        content {
          key   = string_not_like.value.key
          value = string_not_like.value.value
        }
      }
    }
  }

  dynamic "selection_tag" {
    for_each = lookup(each.value, "selection_tags", [])
    content {
      type  = selection_tag.value.tag
      key   = selection_tag.value.key
      value = selection_tag.value.value
    }
  }
}
  