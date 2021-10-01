variable "chart_version" {
  type        = string
  description = "metrics-server helm chart version"
  default     = null
}

variable "namespace" {
  type        = string
  description = "Namespace to apply metrics-server in"
  default     = "monitoring"
  validation {
    condition     = can(regex("[a-z]+", var.string))
    error_message = "Namespace must contain at least one letter."
  }
}
