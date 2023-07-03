variable "deploy_vault" {
  type    = bool
  default = true
}

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
  type = map(object({
    schedule      = string
    delete_after  = number
  }))
  default = {
    "BackupRule" = {
      schedule     = "cron(0 12 * * ? *)"
      delete_after = 14
    }
  }
}

variable "iam_role_name" {
  type    = string
  default = "aws-backup"
}

variable "backup_plan_name" {
  type    = string
  default = "backup-rds"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "additional_tags" {
  type    = map(string)
  default = {}
}
