variable "chart_version" {
  type        = string
  description = "metrics-server helm chart version"
  default     = null
}

variable "namespace" {
  type        = string
  description = "Namespace to apply metrics-server in"
  default     = "monitoring"
}