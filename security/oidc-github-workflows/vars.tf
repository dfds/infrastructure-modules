variable "iam_github_oidc_repositories" {
  type = list(object({
    repository_name = string
    refs            = list(string)
  }))
  default     = []
  description = "List of repositories to authenticate to AWS from. Each object contains repository name and list of git refs that should be allowed to deploy from"
  validation {
    condition     = alltrue([for v in flatten(values({ for repo in var.iam_github_oidc_repositories : repo.repository_name => repo.refs })) : startswith(v, "refs/heads/") || startswith(v, "refs/tags/")])
    error_message = "The ref needs to start with `refs/heads/` for branches and `refs/tags/` for tags."
  }
}

variable "iam_github_oidc_policy_json" {
  type = list(object({
    actions   = list(string)
    resources = list(string)
  }))
  default     = []
  description = "List of allowed actions for the oidc-role"
}

variable "iam_github_oidc_role_name" {
  type        = string
  default     = "oidc-role"
  description = "Name of the role to create"
}

variable "iam_github_oidc_policy_name" {
  type        = string
  default     = "oidc-access"
  description = "Name of the policy to create"
}

variable "aws_region" {
  type        = string
  description = "AWS region where the ECR pull-through cache will be created."
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]$", var.aws_region))
    error_message = "AWS region must be in the format 'eu-central-1', 'eu-west-1', etc."
  }
}

variable "aws_workload_account_id" {
  description = "The ID of the account trusted to assume the role"
  type        = string
}

variable "prime_role_name" {
  type    = string
  default = ""
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

variable "data_tags" {
  type        = map(string)
  description = "A map of tags to apply to all the data and/or storage deployed by the module"
  default     = {}
}
