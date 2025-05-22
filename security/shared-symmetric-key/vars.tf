variable "aws_region" {
  type = string
}

variable "aws_assume_role_arn" {
  type = string
}

variable "key_alias" {
  description = "The alias for the KMS key."
  type        = string
  validation {
    condition     = can(regex("^alias/[a-zA-Z0-9/_-]+$", var.key_alias))
    error_message = "The key alias must start with 'alias/' and contain only alphanumeric characters, underscores, and hyphens."
  }
}

variable "key_user_arns" {
  description = "The users of the KMS key."
  type        = list(string)
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}
