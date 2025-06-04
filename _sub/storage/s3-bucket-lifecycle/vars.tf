variable "acl" {
  type        = string
  description = "The canned ACL to apply. Defaults to 'private'."
  default     = "private"
}

variable "bucket_name" {
  type        = string
  description = "Bucket name."
}

variable "bucket_policy" {
  type        = string
  description = "Bucket policy."
}

variable "force_destroy" {
  type        = bool
  default     = true
  description = "Destroy bucket without error"
}

variable "lifecycle_enabled" {
  type        = bool
  description = "Enable S3 bucket lifecycle."
  default     = true
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

variable "replication" {
  type = map(object({
    destination_account_id  = string
    destination_bucket_arn  = string
    destination_kms_key_arn = optional(string, "")
    source_kms_key_arn      = optional(string, "")
  }))
  default = {}
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

variable "sse_algorithm" {
  type        = string
  description = "The server-side encryption algorithm to use."
  default     = "AES256"
  validation {
    condition     = contains(["aws:kms", "aws:kms:dsse", "AES256"], var.sse_algorithm)
    error_message = "SSE algorithm must be either 'aws:kms', 'aws:kms:dsse' or 'AES256'."
  }
}

variable "versioning_enabled" {
  type        = bool
  description = "Enable S3 bucket versioning."
  default     = false
}
