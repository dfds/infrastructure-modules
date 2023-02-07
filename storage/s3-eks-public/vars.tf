# --------------------------------------------------
# AWS
# --------------------------------------------------

variable "aws_region" {
  type = string
}

variable "aws_assume_role_arn" {
  type = string
}

variable "eks_public_s3_bucket" {
  description = "The name of the public S3 bucket, where non-sensitive Kubeconfig will be copied to."
  type        = string

  validation {
    condition     = length(var.eks_public_s3_bucket) > 0
    error_message = "Bucket name must be a non-empty string"
  }
}

variable "enable_server_side_encryption" {
  description = "Enable server side encryption (SSE) on the S3 bucket"
  type        = bool
  default     = true
}

variable "additional_tags" {
  description = "Add additional tags to s3 bucket"
  type        = map(string)
  default     = {}
}
