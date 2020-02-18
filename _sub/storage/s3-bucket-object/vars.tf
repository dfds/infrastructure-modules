variable "deploy" {
  type    = bool
  default = true
}

variable "bucket" {
  description = "The name of the S3 bucket."
}

variable "key" {
  description = "The name (and path) of the object in the bucket."
}

variable "content" {
  description = "The contents of the object to create in the bucket."
}

variable "acl" {
  description = "The canned ACL to apply. Defaults to 'private'."
  default     = "private"
}

