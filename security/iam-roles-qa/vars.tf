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
