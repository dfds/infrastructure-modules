variable "chart_version" {
  type        = string
  default     = ""
  description = "Kyverno helm chart version"
}

variable "excluded_namespaces" {
  type        = list(string)
  description = "Service policies excluded namespaces"
}

variable "replicas" {
  type        = number
  description = "Number of replica pods"
}

variable "namespace_labels" {
  type    = map(any)
  default = {}
}
