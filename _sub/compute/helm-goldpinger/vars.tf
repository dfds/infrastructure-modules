variable "chart_version" {
  type        = string
  description = "Goldpinger helm chart version"
  default     = ""
}

variable "namespace" {
  type        = string
  description = "Namespace to apply goldpinger in"
  validation {
    condition     = can(regex("[a-z]+", var.namespace))
    error_message = "Namespace must contain at least one letter."
  }
}

variable "priority_class" {
  type        = string
  description = "Name of priority class to apply"
}

variable "servicemonitor_enabled" {
  type        = bool
  description = "Deploy servicemonitor to enable metrics scraping"
  default     = false
}
