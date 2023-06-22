variable "repositories" {
  type = list(object({
    repository_name = string
    branches        = list(string)
  }))
  description = "List of repositories to authenticate to AWS from. Each object contains repository name and list of branches that should be allowed to deploy from"
}

variable "oidc_role_access" {
  type = list(object({
    actions   = list(string)
    resources = list(string)
  }))
  description = "List of allowed actions for the oidc-role"
}
