variable "chart_version" {
  type = string
  description = "Goldpinger helm chart version"
}

variable "namespace" {
  type = string
  description = "Namespace to apply goldpinger in"
  default = "monitoring"
}

variable "priority_class" {
  type = string
  description = "Name of priority class to apply"
  default = "cluster-monitoring"
}

variable "deploy" {
  type = bool
  description = "Deployment switch for goldpinger"
  default = false
}