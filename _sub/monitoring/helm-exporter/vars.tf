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
  description = "The version of the helm Exporter Helm Chart that should be used"
  default     = null
}

variable "monitoring_targets" {
  type        = list(object({ name = string, url = string, module = string }))
  description = "Complex object of what to monitor with helm Exporter"
  default     = []
}
