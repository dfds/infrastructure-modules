variable "s3_bucket" {
  type        = string
  description = "The name of the S3 bucket where CloudTrail logs will be stored."
}

variable "s3_log_bucket" {
  type        = string
  description = "The name of the S3 bucket where server access logs for the bucket with the CloudTrail logs will be stored."
  default     = null
}

variable "retention_days" {
  type        = number
  description = "The number of days to keep CloudTrail logs in s3 bucket."
  default     = 90
}

variable "create_s3_bucket" {
  type    = bool
  default = false
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
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
