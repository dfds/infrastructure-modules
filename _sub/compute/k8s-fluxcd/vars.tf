# --------------------------------------------------
# Flux CD bootstrap variables
# --------------------------------------------------

variable "github_owner" {
  type = string
}

variable "repository_name" {
  type = string
}

variable "branch" {
  type    = string
  default = "main"
}

variable "target_path" {
  type = string
}

# --------------------------------------------------
# Custom variables
# --------------------------------------------------

variable "cluster_name" {
  type = string
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
