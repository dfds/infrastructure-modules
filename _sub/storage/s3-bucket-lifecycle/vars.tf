variable "retention_days" {
  type        = number
  description = "Retention days set on bucket."
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
  type = map(any)
  default = {}
}

variable "is_sandbox" {
  description = "Whether to add sandbox tags to the S3 bucket"
  type = bool
  default = false
}
