variable "vault_name" {
  type        = string
  description = "The name of the Vault."
  default     = ""
}

variable "deploy_kms_key" {
  type        = bool
  description = "Indicates whether a KMS key should be deployed."
  default     = true
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of a the KMS key."
  default     = ""
}

variable "deploy_backup_selection" {
  type        = bool
  description = "Indicates whether a backup selection should be deployed."
  default     = true
}

variable "backup_rules" {
  type = list(object({
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
    }
  ))

  description = "The list of backup rules."
  default     = []
}

variable "iam_role_arn" {
  type        = string
  description = "The ARN of the IAM role."
}

variable "backup_plan_name" {
  type        = string
  description = "The name of the backup plan."
  default     = ""
}

variable "tags" {
  type        = map(string)
  description = "A set of key-value pairs as tags for the resources."
  default     = {}
}

variable "backup_selections" {
  type = list(object({
    name      = string
    resources = optional(list(string))
    conditions = optional(list(object({
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

    })))
    not_resources = optional(list(string))
    selection_tags = optional(list(object({
      tag   = string
      key   = string
      value = string
    })))
  }))
  description = "A list of resources that will be backed up."
  default     = []
}

variable "kms_key_admins" {
  type        = list(string)
  description = "List of IAM Roles ARNs administrator access of the KMS Key."
}


variable "settings_resource_type_opt_in_preference" {
  description = "(Required) A map of services along with the opt-in preferences for the Region."
  default = {
    "Aurora"                 = true
    "CloudFormation"         = true
    "DocumentDB"             = true
    "DynamoDB"               = true
    "EBS"                    = true
    "EC2"                    = true
    "EFS"                    = true
    "FSx"                    = true
    "Neptune"                = true
    "RDS"                    = true
    "Redshift"               = true
    "S3"                     = true
    "SAP HANA on Amazon EC2" = true
    "Storage Gateway"        = true
    "Timestream"             = true
    "VirtualMachine"         = true
  }
}
