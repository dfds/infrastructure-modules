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
}

variable "gitops_apps_repo_url" {
  type        = string
  description = "The https url for your GitOps manifests"
}

variable "gitops_apps_repo_branch" {
  type        = string
  description = "The default branch for your GitOps manifests"
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
# IRSA variables
# --------------------------------------------------

variable "oidc_issuer" {
  type        = string
  description = "The OIDC isssue for the Kubernetes cluster"
}

variable "workload_account_id" {
  type        = string
  description = "The workload account ID."
}

variable "aws_region" {
  type        = string
  description = "The AWS region"
}

# --------------------------------------------------
# Atlantis variables
# --------------------------------------------------

variable "chart_version" {
  type        = string
  description = "The Helm Chart version that should be used"
}

variable "image_tag" {
  type        = string
  description = "Tag of the Atlantis image to use"
}

variable "ingress_hostname" {
  type        = string
  description = "The hostname for the Atlantis ingress"
}

variable "resources_requests_cpu" {
  type        = string
  description = "CPU resources request size"
}

variable "resources_requests_memory" {
  type        = string
  description = "Memory resources requests size"
}

variable "storage_size" {
  type        = string
  description = "Size of the persistent volume"
}
