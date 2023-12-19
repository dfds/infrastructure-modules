#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = string
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

variable "shared_account_id" {
  type        = string
  description = "The AWS account ID of the Organizations Shared account (e.g. Oxygen)"
}

variable "shared_role_path" {
  type        = string
  description = "The path in which to put the IAM role for access to resources in shared account"
  default     = "/"
}

variable "access_key_master" {
  type = string
}

variable "secret_key_master" {
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

variable "context_id" {
  type        = string
  description = "The ID of the context, for which to create and AWS account"
}

variable "correlation_id" {
  type = string
}

variable "capability_root_id" {
  type = string
}

variable "capability_name" {
  type = string
}

variable "capability_id" {
  type = string
}

variable "context_name" {
  type = string
}

variable "kafka_broker" {
  type = string
}

variable "kafka_username" {
  type = string
}

variable "kafka_password" {
  type = string
}

variable "publish_message" {
  type    = bool
  default = true
}

variable "parent_id" {
  type        = string
  description = "The ID of the parent AWS Organization OU."
  default     = ""
}

variable "oidc_provider_url" {
  type        = string
  description = "The IAM OpenID Connect Provider url from the EKS production account"
  default     = ""
}

variable "oidc_provider_tag" {
  type        = string
  description = "Used for tagging the IAM OpenID Connect Provider for the capability account"
  default     = ""
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

variable "aws_region_2" {
  type        = string
  description = "Terraform has limitations that prevent us from dynamically creating AWS providers for each region, so instead of providing a list of regions we will specifiy an incremented set of variables to deploy resources across multiple regions."
  default     = "eu-west-1"
}

variable "repositories" {
  type = list(object({
    repository_name = string
    refs            = list(string)
  }))
  description = "List of repositories to authenticate to AWS from. Each object contains repository name and list of refs that should be allowed to deploy from"
  default     = []
}

variable "oidc_role_access" {
  type = list(object({
    actions   = list(string)
    resources = list(string)
  }))
  description = "List of allowed actions for the oidc-role"
  default     = []
}

variable "deploy_backup" {
  type        = bool
  description = "Whether to deploy AWS Backup"
  default     = false
}

variable "aws_backup_settings_resource_type_opt_in_preference" {
  type        = map(any)
  description = "A map of services along with the opt-in preferences for the Region"
  default     = {}
}

variable "aws_backup_resource_type_management_preference" {
  type        = map(any)
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
  type        = map(string)
  description = "A map of tags to apply to the backup components"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}
