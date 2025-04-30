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

variable "additional_tags" {
  description = "Add additional tags to s3 bucket"
  type        = map(any)
  default     = {}
}

variable "velero_role_arn" {
  description = "Which role arn can use the bucket?"
  type        = string
  default     = null
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

variable "replication_enabled" {
  type        = bool
  description = "Enable S3 bucket replication."
  default     = false
}

variable "replication_source_role_arn" {
  type        = string
  description = "The ARN of the IAM role to use for S3 bucket replication."
  default     = null
}

variable "replication_destination_account_id" {
  type        = string
  description = "The account ID of the destination bucket."
  default     = null
}

variable "replication_destination_bucket_arn" {
  type        = string
  description = "The ARN of the destination bucket."
  default     = null
}

variable "replication_destination_kms_key_arn" {
  type        = string
  description = "The ARN of the KMS key to use for encryption of the destination bucket."
  default     = null
}

variable "retention_days" {
  type        = number
  description = "Retention days set on bucket."
  default     = 30
  validation {
    condition     = var.retention_days > 0
    error_message = "Retention days must be greater than 0."
  }
}
