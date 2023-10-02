variable "cluster_name" {
  type = string
}

variable "deploy_name" {
  type        = string
  description = "Unique identifier of the deployment, only needs override if deploying multiple instances"
  default     = "datadog-operator"
}

variable "namespace" {
  type        = string
  default     = "datadog"
  description = "The namespace in which to deploy Helm resources"
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
  description = "The version of the DataDog Helm Chart that should be used"
  default     = null
}

variable "interval_duration" {
  type        = string
  description = "Interval between scrapes of Helm releases"
  default     = "10m"
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

variable "api_secret_name" {
  type    = string
  default = "datadog-secret"
}

variable "api_secret_key" {
  type    = string
  default = "api-key"
}

variable "app_secret_name" {
  type    = string
  default = "datadog-secret"
}

variable "app_secret_key" {
  type    = string
  default = "app-key"
}

variable "node_agent_image_version" {
  type    = string
  default = "latest"
}

variable "site" {
  type    = string
  default = "datadoghq.eu"
}

variable "tolerations" {
  type = list(object({
    key      = string,
    operator = string,
    value    = optional(string),
    effect   = string,
  }))
  default = []
}

variable "prune" {
  type        = bool
  default     = true
  description = "Enable Garbage collection"
}
