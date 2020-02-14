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

