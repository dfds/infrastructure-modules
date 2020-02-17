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

variable "account_id_workload" {
  description = "The ID of the account trusted to assume the role"
  type        = string
}

variable "admin_iam_policy_name" {
  description = "Policy granting access to create new AWS Organization accounts"
  type        = string
}

