variable "vault_name" {
  type    = string
  default = ""
}

variable "deploy_kms_key" {
  type    = bool
  default = true
}

variable "kms_key_arn" {
  type    = string
  default = ""
}

variable "deploy_backup_selection" {
  type    = bool
  default = true
}

variable "backup_selection_name" {
  type    = string
  default = ""
}

variable "backup_resources" {
  type    = list(string)
  default = []
}

variable "backup_rules" {
  type = list(object({
    name          = string
    schedule      = string
    delete_after  = number
  }))
  default = [
    {
      name         = "BackupRule"
      schedule     = "cron(0 12 * * ? *)"
      delete_after = 14
    }
  ]
}

variable "iam_role_arn" {
  type    = string
}

variable "backup_plan_name" {
  type    = string
  default = "backup-rds"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "selection_tags" {
  type    = list(object({
    type    = string
    key     = string
    value   = string
  }))
  default = []
}

variable "advanced_backup_setting_resource_type" {
  type    = string
  default = "RDS"
}

variable "advanced_backup_settings" {
  type = map(object({
    windows_vss = bool
  }))
}
