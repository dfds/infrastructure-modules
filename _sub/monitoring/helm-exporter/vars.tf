variable "cluster_name" {
  type = string
}

variable "deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "helm-exporter"
}

variable "namespace" {
  type        = string
  default     = "monitoring"
  description = "The namespace in which to deploy Helm resources"
}

variable "replicas" {
  description = "The number of helm pods to spawn"
  type        = number
  default     = 1
}

variable "github_owner" {
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

variable "helm_chart_version" {
  type        = string
  description = "The version of the Helm Exporter Helm Chart that should be used"
  default     = ""
}

variable "interval_duration" {
  type        = string
  description = "Interval between scrapes of Helm releases"
  default     = "10m"
}

variable "target_namespaces" {
  type        = string
  description = "Filter on namespaces"
  default     = ""
}

variable "target_charts" {
  type = list(object({
    registry = object({
      url = string
    })
    charts = list(string)
  }))
  default = []
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
