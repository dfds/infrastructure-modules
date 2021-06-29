variable "retention_days" {
  type        = number
  description = "Retention days set on S3 bucket"
}

variable "name" {
  type        = string
  description = "The name of the S3 Bucket."
}

variable "acl" {
  type        = string
  description = "The canned ACL to apply. Defaults to 'private'."
  default     = "private"
}
