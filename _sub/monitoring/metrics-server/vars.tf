variable "cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
}

variable "deploy_name" {
  type        = string
  description = "Unique identifier of the deployment"
  default     = "metrics-server"
}

variable "namespace" {
  type        = string
  default     = "metrics-server"
  description = "The namespace to deploy the helm chart"
}

variable "chart_version" {
  type        = string
  description = "The helm chart version"
  default     = ""
}

variable "repo_owner" {
  type        = string
  description = "Name of the Github owner (previously: organization)"
}

variable "repo_name" {
  type        = string
  description = "Name of the Github repo to store the manifests in"
}

variable "repo_branch" {
  type        = string
  description = "Override the default branch of the repo (optional)"
  default     = null
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
