variable "helm_chart_version" {
  type        = string
  description = "metrics-server helm chart version"
  default     = null
}

variable "namespace" {
  type        = string
  description = "Namespace to apply metrics-server in"
  validation {
    condition     = can(regex("[a-z]+", var.namespace))
    error_message = "Namespace must contain at least one letter."
  }
}

variable "helm_repo_url" {
  type        = string
  description = "The repository URL for the metrics-server Helm chart"
  default     = "https://kubernetes-sigs.github.io/metrics-server/"
}
