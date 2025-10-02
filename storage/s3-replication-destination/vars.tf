variable "aws_region" {
  type = string
}

variable "aws_assume_role_arn" {
  type = string
}

variable "bucket_name" {
  type        = string
  description = "Replication destination bucket name"
}

variable "replication_role_arn" {
  description = "Which role arn can write to the bucket?"
  type        = string
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

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

variable "data_tags" {
  type        = map(string)
  description = "A map of tags to apply to all the data and/or storage deployed by the module"
  default     = {}
}
