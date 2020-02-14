variable "aws_region" {
  type = string
}

variable "iam_user_name" {
  description = "Name of IAM user"
  type        = string
}

variable "create_org_account_iam_policy_name" {
  description = "Policy granting access to create new AWS Organization accounts"
  type        = string
}

variable "assume_noncore_accounts_iam_policy_name" {
  description = "Policy granting access to create new AWS Organization accounts"
  type        = string
}

variable "core_account_role_arns" {
  description = "List of core account (e.g. Core, QA, Master, Security) root ARNs"
  type        = list(string)
}

# --------------------------------------------------
# Unused variables - to provent TF warning/error:
# Using a variables file to set an undeclared variable is deprecated and will
# become an error in a future release. If you wish to provide certain "global"
# settings to all configurations in your organization, use TF_VAR_...
# environment variables to set these instead.
# --------------------------------------------------

variable "aws_account_name" {
  type    = string
  default = ""
}

variable "terraform_state_region" {
  type    = string
  default = ""
}

variable "cloudtrail_central_s3_bucket" {
  type    = string
  default = ""
}

variable "terraform_state_s3_bucket" {
  type    = string
  default = ""
}

variable "terraform_state_aws_region" {
  type    = string
  default = ""
}