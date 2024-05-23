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

variable "release_tag" {
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

variable "overwrite_on_create" {
  type        = bool
  default     = true
  description = "Enable overwriting existing files"
}

variable "prune" {
  type        = bool
  default     = true
  description = "Enable Garbage collection"
}

variable "endpoint" {
  type = string
}

variable "token" {
  type = string
}

variable "cluster_ca_certificate" {
  type = string
}
