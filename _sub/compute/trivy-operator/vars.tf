variable "cluster_name" {
  type = string
}

variable "chart_version" {
  type        = string
  description = "The Helm Chart version that should be used"
  default     = ""
}

variable "deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "trivy-operator"
}

variable "namespace" {
  type        = string
  description = "Namespace to deploy the application into"
  default     = "trivy-system"
}

variable "resources_requests_cpu" {
  type        = string
  default     = "100m"
  description = "CPU resources request size"
}

variable "resources_requests_memory" {
  type        = string
  default     = "128Mi"
  description = "Memory resources requests size"
}

variable "resources_limits_cpu" {
  type        = string
  default     = "500m"
  description = "CPU resources limits size"
}

variable "resources_limits_memory" {
  type        = string
  default     = "1024Mi"
  description = "Memory resources limits size"
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
  default     = "main"
}

variable "overwrite_on_create" {
  type        = bool
  default     = true
  description = "Enable overwriting existing files"
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

variable "prune" {
  type        = bool
  default     = true
  description = "Enable Garbage collection"
}
