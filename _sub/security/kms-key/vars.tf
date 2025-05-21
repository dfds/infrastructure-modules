variable "description" {
  description = "The description of the KMS key."
  type        = string
  default     = "Customer managed key"
}

variable "key_alias" {
  description = "The alias for the KMS key."
  type        = string
  validation {
    condition     = can(regex("^alias/[a-zA-Z0-9/_-]+$", var.key_alias))
    error_message = "The key alias must start with 'alias/' and contain only alphanumeric characters, underscores, and hyphens."
  }
}

variable "key_admin_arns" {
  description = "The administrator of the KMS key."
  type        = list(string)
  default     = []
}

variable "key_user_arns" {
  description = "The users of the KMS key."
  type        = list(string)
  default     = []
}

variable "key_usage" {
  description = "The key usage for the KMS key."
  type        = string
  default     = "ENCRYPT_DECRYPT"
}

variable "enable_key_rotation" {
  description = "Whether to enable key rotation for the KMS key."
  type        = bool
  default     = true
}

variable "rotation_period_in_days" {
  description = "The rotation period in days for the KMS key."
  type        = number
  default     = 90
}

variable "deletion_window_in_days" {
  description = "The number of days before the KMS key can be deleted."
  type        = number
  default     = 30
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
