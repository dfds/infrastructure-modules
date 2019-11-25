# --------------------------------------------------
# AWS
# --------------------------------------------------

variable "aws_region" {
  type = "string"
}

variable "aws_assume_role_arn" {
  type = "string"
}

variable "eks_public_s3_bucket" {
  description = "The name of the public S3 bucket, where non-sensitive Kubeconfig will be copied to."
  type = "string"
  default = ""
}