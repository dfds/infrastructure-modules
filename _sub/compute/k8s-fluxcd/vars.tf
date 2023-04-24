variable "cluster_name" {
  type = string
}

variable "repo_name" {
  type        = string
  description = ""
}

variable "repo_branch" {
  type        = string
  default     = "main"
  description = ""
}

variable "repo_path" {
  type        = string
  description = ""
}

variable "github_owner" {
  type        = string
  description = ""
}

variable "gitops_apps_repo_url" {
  type        = string
  default     = ""
  description = "The https url for your GitOps manifests"
}

variable "gitops_apps_repo_branch" {
  type        = string
  default     = "main"
  description = "The default branch for your GitOps manifests"
}

variable "kubeconfig_path" {
  type    = string
  default = null
}

variable "release_tag" {
  type    = string
  default = "latest"
}

variable "overwrite_on_create" {
  type        = bool
  default     = true
  description = "Enable overwriting existing files"
}
