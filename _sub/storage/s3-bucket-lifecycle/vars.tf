variable "retention_days" {
  type        = number
  description = "Retention days set on bucket."
}

variable "lifecycle_rule_name" {
  type        = string
  description = "The name of the lifecycle rule."
  default     = "retention_policy"
}

variable "name" {
  type        = string
  description = "Bucket name."
}

variable "acl" {
  type        = string
  description = "The canned ACL to apply. Defaults to 'private'."
  default     = "private"
}

variable "policy" {
  type        = string
  description = "Bucket policy."
}

variable "additional_tags" {
  description = "Add additional tags to s3 bucket"
  type        = map(any)
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

variable "replication_rule_name" {
  type        = string
  description = "The name of the replication rule."
  default     = "replication_rule"
}

variable "object_ownership" {
  type        = string
  description = "The object ownership controls for the bucket."
  default     = "BucketOwnerPreferred"
  validation {
    condition     = contains(["BucketOwnerPreferred", "BucketOwnerEnforced", "ObjectWriter"], var.object_ownership)
    error_message = "Ownership controls must be either 'BucketOwnerPreferred', 'BucketOwnerEnforced' or 'ObjectWriter'."
  }
}
