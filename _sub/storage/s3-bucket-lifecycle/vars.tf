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
