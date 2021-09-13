variable "iam_role_trusted_account_root_arn" {
  description = "The ARN of the account trusted to assume the role"
  type        = list(string)
  default     = []
}

variable "replace_token" {
  description = "The name of the token to replace in policies, e.g. a capability root id"
  type = string
  default = "" #tfsec:ignore:general-secrets-sensitive-in-variable
}


variable "core_account_role_arns" {
  description = "List of core account (e.g. Core, QA, Master, Security) root ARNs"
  type        = list(string)
  default     = []
}
