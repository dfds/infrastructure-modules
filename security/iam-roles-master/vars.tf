variable "aws_region" {
  type = string
}

variable "iam_role_name" {
  description = "Name of IAM role"
  type        = string
}

variable "iam_role_description" {
  description = "Description for IAM role"
  type        = string
}

variable "iam_role_trusted_account_root_arn" {
  description = "The ARN of the account trusted to assume the role"
  type        = string
}

variable "create_org_account_iam_policy_name" {
  description = "Policy granting access to create new AWS Organization accounts"
  type        = string
}

