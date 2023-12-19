data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

resource "aws_backup_region_settings" "this" {
  count = length(var.settings_resource_type_opt_in_preference) > 0 ? 1 : 0

  resource_type_opt_in_preference     = var.settings_resource_type_opt_in_preference
  resource_type_management_preference = var.resource_type_management_preference
}

resource "aws_backup_vault" "vault" {
  name        = var.new_vault_name
  tags        = var.tags
}

resource "aws_backup_plan" "this" {
  for_each = { for config in var.backup_plans : config.plan_name => config }
  name     = each.value.plan_name

  dynamic "rule" {
    for_each = each.value.rules != null ? each.value.rules : []

    content {
      rule_name                = rule.value.name
      target_vault_name        = aws_backup_vault.vault.name
      schedule                 = lookup(rule.value, "schedule", null)
      enable_continuous_backup = lookup(rule.value, "enable_continuous_backup", false)
      start_window             = lookup(rule.value, "start_window", null)
      completion_window        = lookup(rule.value, "completion_window", null)
      recovery_point_tags      = lookup(rule.value, "recovery_point_tags", {})

      dynamic "lifecycle" {
        for_each = length(lookup(rule.value, "lifecycle", {})) > 0 ? ["OK"] : []
        content {
          cold_storage_after = lookup(rule.value.lifecycle, "cold_storage_after", 0)
          delete_after       = lookup(rule.value.lifecycle, "delete_after", 30)
        }
      }

      dynamic "copy_action" {
        for_each = lookup(rule.value, "copy_action", []) != null ? rule.value.copy_action : []
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
    }
  }

  tags = var.tags
}

resource "aws_backup_selection" "this" {
  for_each = merge([
    for config in var.backup_plans : {
      for selection in config.selections : "${config.plan_name}-${selection.name}" => merge(selection, { backup_plan_name = config.plan_name })
    }
  ]...)

  name          = each.value.name
  iam_role_arn  = var.iam_role_arn
  plan_id       = aws_backup_plan.this[each.value.backup_plan_name].id
  resources     = lookup(each.value, "resources", [])
  not_resources = lookup(each.value, "not_resources", [])

  dynamic "condition" {
    for_each = length(lookup(each.value, "conditions", {})) > 0 ? [each.value.conditions] : []
    content {
      dynamic "string_equals" {
        for_each = lookup(condition.value, "string_equals", []) != null ? condition.value.string_equals : []
        content {
          key   = string_equals.value.key
          value = string_equals.value.value
        }
      }
      dynamic "string_like" {
        for_each = lookup(condition.value, "string_like", []) != null ? condition.value.string_like : []
        content {
          key   = string_like.value.key
          value = string_like.value.value
        }
      }
      dynamic "string_not_equals" {
        for_each = lookup(condition.value, "string_not_equals", []) != null ? condition.value.string_not_equals : []
        content {
          key   = string_not_equals.value.key
          value = string_not_equals.value.value
        }
      }
      dynamic "string_not_like" {
        for_each = lookup(condition.value, "string_not_like", []) != null ? condition.value.string_not_like : []
        content {
          key   = string_not_like.value.key
          value = string_not_like.value.value
        }
      }
    }
  }

  dynamic "selection_tag" {
    for_each = lookup(each.value, "selection_tags", []) != null ? each.value.selection_tag : []
    content {
      type  = selection_tag.value.tag
      key   = selection_tag.value.key
      value = selection_tag.value.value
    }
  }
}
