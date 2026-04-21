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

variable "blocked_encryption_types" {
  description = "List of encryption types that are blocked for the S3 bucket"
  type        = list(string)
  default     = ["SSE-C"]
  validation {
    condition     = alltrue([for t in var.blocked_encryption_types : contains(["SSE-C", "NONE"], t)])
    error_message = "Blocked encryption types must be either 'SSE-C' or 'NONE'"
  }
}


variable "additional_tags" {
  description = "Add additional tags to s3 bucket"
  type        = map(any)
  default     = {}
}
