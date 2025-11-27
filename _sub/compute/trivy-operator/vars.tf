variable "cluster_name" {
  type = string
}

variable "chart_version" {
  type        = string
  description = "The Helm Chart version that should be used"
  default     = ""
}

variable "resources_requests_cpu" {
  type        = string
  description = "CPU resources request size"
}

variable "resources_requests_memory" {
  type        = string
  description = "Memory resources requests size"
}

variable "scan_resources_requests_cpu" {
  type        = string
  description = "CPU resources requests size for scan containers"
}

variable "scan_resources_requests_memory" {
  type        = string
  description = "Memory resources requests size for scan containers"
}

variable "github_token" {
  type        = string
  description = "Github token to authenticate with"
  sensitive   = true
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

variable "gitops_apps_repo_ref" {
  type        = string
  description = "The default branch or tag for your GitOps manifests"
}

variable "prune" {
  type        = bool
  default     = true
  description = "Enable Garbage collection"
}
