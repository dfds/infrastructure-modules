variable "namespace" {
  default = "cert-manager"
  type = string
  description = "Namespace to create and deploy cert-manager in."
}

variable "chart_version" {
  default = null
  type = string
  description = "Helm chart version."
}

variable "enable_servicemonitor" {
  default = true
  type = bool
  description = "Should the helm chart deploy a servicemonitor resource, highly dependent on kube-prometheus-stack."
}

variable "priority_class" {
  type = string
  description = "Priority class to use for deployment."
}
