variable "cluster_name" {
  type = string
}

variable "repo_name" {
  type        = string
  description = "Name of the Github repo to store the manifests in"
}

variable "repo_branch" {
  type        = string
  description = "Override the default branch of the repo (optional)"
  default     = "main"
}

variable "apps_repo_url" {
  type        = string
  default     = ""
  description = "The https url for your GitOps manifests"
}

variable "apps_repo_ref" {
  type        = string
  default     = "main"
  description = "The default branch or tag for your GitOps manifests"
}

variable "is_sandbox" {
  type = bool
  description = "Is the cluster sandbox/non-prod"
}

