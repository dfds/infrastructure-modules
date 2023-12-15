variable "aws_region" {
  type = string
}

variable "iam_user_name" {
  description = "Name of IAM user"
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

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}
