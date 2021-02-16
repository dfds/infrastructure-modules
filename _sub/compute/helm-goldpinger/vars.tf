variable "chart_version" {
  type        = string
  description = "Goldpinger helm chart version"
  default     = null
}

variable "namespace" {
  type        = string
  description = "Namespace to apply goldpinger in"
  default     = "monitoring"
}

variable "priority_class" {
  type        = string
  description = "Name of priority class to apply"
}

variable "servicemonitor_enabled" {
  type = bool
  description = "Deploy servicemonitor to enable metrics scraping"
  default = false
}
