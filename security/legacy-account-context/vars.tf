variable "aws_region" {
  type = string
}

variable "aws_region_2" {
  type        = string
  description = "Terraform has limitations that prevent us from dynamically creating AWS providers for each region, so instead of providing a list of regions we will specifiy an incremented set of variables to deploy resources across multiple regions."
}

variable "aws_session_name" {
  type        = string
  description = "An identifier for the AWS session name. This can be useful in identifiying which pipeline executed the Terraform."
  default     = null
}

variable "master_account_id" {
  type        = string
  description = "The AWS account ID of the Organizations Master account"
}

variable "core_account_id" {
  type        = string
  description = "The AWS account ID of the Organizations Core account"
}

variable "security_account_id" {
  type = string
  description = "The AWS account ID of the Organizations Security account"
}

variable "access_key_master" {
  type = string
}

variable "secret_key_master" {
  type = string
}

variable "account_id" {
  type = string
}

variable "name" {
  type = string
}

variable "org_role_name" {
  type = string
}

variable "prime_role_name" {
  type = string
}

variable "email" {
  type = string
}

variable "parent_id" {
  type        = string
  description = "The ID of the parent AWS Organization OU."
  default     = ""
}

variable "aws_region_sso" {
  type    = string
  default = "eu-west-1"
}

variable "sso_support_permission_set_name" {
  type    = string
  default = null
}

variable "sso_support_group_name" {
  type    = string
  default = null
}

variable "harden" {
  type    = bool
  default = false
}

variable "security_bot_lambda_version" {
  type = string
}

variable "security_bot_lambda_s3_bucket" {
  type        = string
  description = "The S3 bucket where the Security Bot Lambda package is stored."
}

variable "hardened_monitoring_email" {
  type    = string
  default = null
}

variable "hardened_monitoring_slack_channel" {
  type    = string
  default = null
}

variable "hardened_monitoring_slack_token" {
  type      = string
  sensitive = true
  default   = null
}

variable "hardened_security_contact_name" {
  type = string
}

variable "hardened_security_contact_title" {
  type = string
}

variable "hardened_security_contact_email" {
  type = string
}

variable "hardened_security_contact_phone_number" {
  type = string
}

variable "deploy_backup" {
  type        = bool
  description = "Whether to deploy AWS Backup"
  default     = false
}

variable "aws_backup_settings_resource_type_opt_in_preference" {
  type        = object({})
  description = "A map of services along with the opt-in preferences for the Region"
  default     = {}
}

variable "aws_backup_resource_type_management_preference" {
  type        = object({})
  description = "A map of services along with the management preferences for the Region"
  default     = {}
}

variable "aws_backup_vault_name_new" {
  type        = string
  description = "Name of the AWS Backup vault"
  default     = null
}

variable "aws_backup_plans" {
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
  default     = []
}

variable "aws_backup_tags" {
  type        = object({})
  description = "A map of tags to apply to the backup components"
  default     = {}
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

# --------------------------------------------------
# IAM role for Grafana Cloud Cloudwatch integration
# --------------------------------------------------

variable "grafana_cloud_cloudwatch_integration_iam_role" {
  type = object({
    arn       = string
    stack_ids = list(string)
  })
  description = "IAM role used for Grafana Cloud IAM CloudWatch access"
  default     = null
}

# --------------------------------------------------
# Steampipe
# --------------------------------------------------

variable "steampipe_audit_role_name" {
  type = string
  description = "Name of the IAM role used by Steampipe for reading resources"
  default = "steampipe-audit"
}