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
  default     = "nvidia-device-plugin"
}

variable "namespace" {
  type        = string
  description = "The namespace in which to deploy Helm resources"
  default     = "nvidia-device-plugin"
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

variable "affinity" {
  type = list(object({
    key      = string
    operator = string
    values   = list(string)
  }))
  description = "A list of affinities to apply to the nvidia device plugin deployment"
}

variable "tolerations" {
  type = list(object({
    key      = string
    operator = string
    value    = optional(string)
    effect   = string
  }))
  description = "A list of tolerations to apply to the nvidia device plugin deployment"
  default     = []
}
