variable "deploy" {
  type    = bool
  default = true
}

variable "s3_bucket" {
  description = "The name of the S3 Bucket."
}

variable "acl" {
  description = "The canned ACL to apply. Defaults to 'private'."
  default     = "private"
}

