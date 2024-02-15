#Initializes the variables needed to generate a new account
#The values vill be propagated via a tfvars file
variable "aws_region" {
  type = string
}

variable "aws_region_2" {
  type        = string
  description = "Terraform has limitations that prevent us from dynamically creating AWS providers for each region, so instead of providing a list of regions we will specifiy an incremented set of variables to deploy resources across multiple regions."
  default     = "eu-west-1"
}

variable "name" {
  type = string
}

variable "org_role_name" {
  type = string
}

variable "email" {
  type = string
}

variable "cloudtrail_local_s3_bucket" {
  type    = string
  default = ""
}

variable "create_cloudtrail_s3_bucket" {
  type    = bool
  default = false
}

variable "cloudtrail_central_s3_bucket" {
  type = string
}

variable "master_account_id" {
  type        = string
  description = "The AWS account ID of the Organizations Master account"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

variable "iam_github_oidc_enabled" {
  type        = bool
  description = "Enable or disable the creation of the IAM role for GitHub OIDC"
  default     = false
}

variable "iam_github_oidc_repositories" {
  type = list(object({
    repository_name = string
    refs            = list(string)
  }))
  description = "List of repositories to authenticate to AWS from. Each object contains repository name and list of git refs that should be allowed to deploy from"
  validation {
    condition     = alltrue([for v in flatten(values({ for repo in var.repositories : repo.repository_name => repo.refs })) : startswith(v, "refs/heads/") || startswith(v, "refs/tags/")])
    error_message = "The ref needs to start with `refs/heads/` for branches and `refs/tags/` for tags."
  }
}

variable "iam_github_oidc_policy_json" {
  type = list(object({
    actions   = list(string)
    resources = list(string)
  }))
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
  description = "Name of the role to create"
}
