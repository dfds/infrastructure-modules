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
  default     = ""
}

variable "enable_server_side_encryption" {
  description = "Enable server side encryption (SSE) on the S3 bucket"
  type = bool
  default = true
}

variable "additional_tags" {
  description = "Add additional tags to s3 bucket"
  type = map(string)
  default = {}
}

# --------------------------------------------------
# Unused variables - to provent TF warning/error:
# Using a variables file to set an undeclared variable is deprecated and will
# become an error in a future release. If you wish to provide certain "global"
# settings to all configurations in your organization, use TF_VAR_...
# environment variables to set these instead.
# --------------------------------------------------

variable "terraform_state_region" {
  type    = string
  default = ""
}

variable "aws_workload_account_id" {
  type    = string
  default = ""
}

variable "workload_dns_zone_name" {
  type    = string
  default = ""
}

variable "terraform_state_s3_bucket" {
  type    = string
  default = ""
}