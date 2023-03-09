variable "deploy" {
  type    = bool
  default = true
}

variable "s3_bucket" {
  type        = string
  description = "The name of the S3 Bucket."
}

variable "acl" {
  type        = string
  description = "The canned ACL to apply. Defaults to 'private'."
  default     = "private"
}

variable "enable_server_side_encryption" {
  description = "Enable server side encryption (SSE) on the S3 bucket"
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Add additional tags to s3 bucket"
  type        = map(any)
  default     = {}
}
