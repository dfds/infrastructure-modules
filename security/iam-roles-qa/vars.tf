variable "aws_region" {
  type = string
}

variable "aws_workload_account_id" {
  description = "The ID of the account trusted to assume the role"
  type        = string
}

variable "prime_role_name" {
  type    = string
  default = ""
}

variable "qa_iam_role_name" {
  description = "Name of IAM role"
  type        = string
}

variable "qa_iam_role_description" {
  description = "Description for IAM role"
  type        = string
}

variable "qa_iam_policy_name" {
  description = "Policy granting access to create new AWS Organization accounts"
  type        = string
}

variable "qa_iam_role_trusted_account_root_arn" {
  description = "The ARN of the account trusted to assume the role"
  type        = list(string)
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

variable "workload_dns_zone_name" {
  type    = string
  default = ""
}

variable "terraform_state_s3_bucket" {
  type    = string
  default = ""
}

