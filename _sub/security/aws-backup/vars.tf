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

variable "backup_selection_name" {
  type        = string
  description = "The name of the backup selection."
  default     = ""
}

variable "backup_resources" {
  type        = list(string)
  description = "The list of resources to be backed up."
  default     = []
}

variable "backup_rules" {
  type        = list(object({
    name         = string
    schedule     = string
    delete_after = number
  }))
  description = "The list of backup rules."
  default = [
    {
      name         = "BackupRule"
      schedule     = "cron(0 12 * * ? *)"
      delete_after = 14
    }
  ]
}

variable "iam_role_arn" {
  type        = string
  description = "The ARN of the IAM role."
}

variable "backup_plan_name" {
  type        = string
  description = "The name of the backup plan."
  default     = "backup-rds"
}

variable "tags" {
  type        = map(string)
  description = "A set of key-value pairs as tags for the resources."
  default     = {}
}

variable "selection_tags" {
  type        = list(object({
    type  = string
    key   = string
    value = string
  }))
  description = "The list of selection tags."
  default     = []
}

variable "advanced_backup_setting_resource_type" {
  type        = string
  description = "The resource type for advanced backup settings."
  default     = "RDS"
}

variable "advanced_backup_settings" {
  type        = map(object({
    windows_vss = bool
  }))
}
