variable "aws_region" {
  type = string
}

variable "aws_assume_role_arn" {
  type = string
}

variable "bucket_name" {
  type        = string
  description = "Velero storage bucket name"
}

variable "velero_role_arn" {
  description = "Which role arn can use the bucket?"
  type        = string
  default     = null
}

variable "replication" {
  type = map(object({
    destination_account_id = string
    destination_bucket_arn = string
    kms_encryption_key_arn = optional(string, "")
  }))
  default = {}
}

variable "replication_role_arn" {
  type        = string
  description = "The ARN of the IAM role to use for S3 bucket replication."
  default     = null
}

variable "retention_days" {
  type        = number
  description = "Retention days set on bucket."
  default     = 15
  validation {
    condition     = var.retention_days > 0
    error_message = "Retention days must be greater than 0."
  }
}

variable "sse_algorithm" {
  type        = string
  description = "The server-side encryption algorithm to use."
  default     = "AES256"
  validation {
    condition     = contains(["aws:kms", "aws:kms:dsse", "AES256"], var.sse_algorithm)
    error_message = "SSE algorithm must be either 'aws:kms', 'aws:kms:dsse' or 'AES256'."
  }
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

variable "data_tags" {
  type        = map(string)
  description = "A map of tags to apply to all the data and/or storage deployed by the module"
  default     = {}
}
