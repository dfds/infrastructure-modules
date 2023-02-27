variable "deploy" {
  type    = bool
  default = true
}

variable "bucket" {
  type        = string
  description = "The name of the S3 bucket."
}

variable "key" {
  type        = string
  description = "The name (and path) of the object in the bucket."
}

variable "content" {
  type        = string
  description = "The contents of the object to create in the bucket."
}

variable "acl" {
  type        = string
  description = "The canned ACL to apply. Defaults to 'private'."
  default     = "private"
}

