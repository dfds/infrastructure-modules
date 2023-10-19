# TODO: This variable needs to be renamed to `vault_name` after we remove the vault we created initially.
variable "new_vault_name" {
  type        = string
  description = "The name of the vault."
  default     = null
}

variable "vault_name" {
  type        = string
  description = "The name of the vault we created initially. This vault will eventually be removed."
  default     = null
}

variable "deploy_kms_key" {
  type        = bool
  description = "Indicates whether a KMS key should be deployed."
  default     = true
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of a the KMS key."
  default     = null
}

variable "backup_plans" {
  type = list(object({
    plan_name = string

    rules = list(object({
      name                     = string
      schedule                 = optional(string)
      enable_continuous_backup = optional(bool)
      start_window             = optional(string)
      completion_window        = optional(string)
      recovery_point_tags      = optional(any)
      copy_action = optional(list(object({
        destination_vault_arn = optional(string)
        lifecycle = object({
          cold_storage_after = optional(number)
          delete_after       = optional(number)
          }
        )
      })))

      lifecycle = object({
        cold_storage_after = optional(number)
        delete_after       = optional(number)
      })
    }))

    selections = list(object({
      name      = string
      resources = optional(list(string))
      conditions = optional(object({
        string_equals = optional(list(object({
          key   = optional(string)
          value = optional(string)
        })))
        string_like = optional(list(object({
          key   = optional(string)
          value = optional(string)
        })))
        string_not_equals = optional(list(object({
          key   = optional(string)
          value = optional(string)
        })))
        string_not_like = optional(list(object({
          key   = optional(string)
          value = optional(string)
        })))
      }))
      not_resources = optional(list(string))
      selection_tags = optional(list(object({
        tag   = string
        key   = string
        value = string
      })))
    }))
  }))
  description = "A list of backup plans."
  default = []
}

variable "iam_role_arn" {
  type        = string
  description = "The ARN of the IAM role."
}

variable "tags" {
  type        = map(string)
  description = "A set of key-value pairs as tags for the resources."
}

variable "kms_key_admins" {
  type        = list(string)
  description = "List of IAM Roles ARNs administrator access of the KMS Key."
}


variable "settings_resource_type_opt_in_preference" {
  description = "A map of services along with the opt-in preferences for the Region."
  type        = map(any)
  default     = {}
}

variable "resource_type_management_preference" {
  type        = map(any)
  description = "A map of services along with the management preferences for the Region"
  default     = {}
}
