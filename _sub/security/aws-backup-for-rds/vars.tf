variable "vault_name" {
  description = "The name of the AWS Vault"
  type        = string
}

variable "iam_role_name" {
  description = "The name of the IAM role for backup"
  type        = string
}

variable "kms_key_alias" {
  description = "The alias of the KMS key for encryption"
  type        = string
}

variable "backup_plan_name" {
  description = "The name of the backup plan"
  type        = string
}