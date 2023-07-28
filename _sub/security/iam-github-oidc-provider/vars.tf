variable "repositories" {
  type = list(object({
    repository_name = string
    refs            = list(string)
  }))
  description = "List of repositories to authenticate to AWS from. Each object contains repository name and list of git refs that should be allowed to deploy from"
  validation {
    condition = alltrue([ for v in flatten(values({ for repo in var.repositories : repo.repository_name => repo.refs })) : startswith(v, "refs/heads/") || startswith(v, "refs/tags/") ])
    error_message = "The ref needs to start with `refs/heads/` for branches and `refs/tags/` for tags."
  }
}

variable "oidc_role_access" {
  type = list(object({
    actions   = list(string)
    resources = list(string)
  }))
  description = "List of allowed actions for the oidc-role"
}
