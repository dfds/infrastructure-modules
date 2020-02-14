variable "iam_role_trusted_account_root_arn" {
  description = "The ARN of the account trusted to assume the role"
  type        = list(string)
  default     = []
}

variable "core_account_role_arns" {
  description = "List of core account (e.g. Core, QA, Master, Security) root ARNs"
  type        = list(string)
  default     = []
}