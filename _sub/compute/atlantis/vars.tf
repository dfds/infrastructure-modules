# --------------------------------------------------
# Flux CD variables
# --------------------------------------------------

variable "cluster_name" {
  type = string
}

variable "repo_owner" {
  type        = string
  description = "Name of the repo owner (previously: organization)"
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

variable "gitops_apps_repo_url" {
  type        = string
  description = "The https url for your GitOps manifests"
}

variable "gitops_apps_repo_ref" {
  type        = string
  description = "The default branch or tag for your GitOps manifests"
}

variable "prune" {
  type        = bool
  default     = true
  description = "Enable Garbage collection"
}

# --------------------------------------------------
# GitHub integration variables
# --------------------------------------------------

variable "github_repositories" {
  description = "List of repositories to whitelist for Atlantis"
  type        = list(string)
}

variable "github_token" {
  type        = string
  description = "Github token that the provider uses to perform Github operations. Leaving unset will fall back to GITHUB_TOKEN environment variable"
  sensitive   = true
}

variable "github_username" {
  type        = string
  description = "Github username of the account that will post Atlantis comments on PR's"
}

# --------------------------------------------------
# Atlantis variables
# --------------------------------------------------

variable "eks_fqdn" {
  type        = string
  description = "The FQDN for the EKS cluster"
}

variable "resources_requests_cpu" {
  type        = string
  description = "CPU resources request size"
}

variable "resources_requests_memory" {
  type        = string
  description = "Memory resources requests size"
}
