variable "chart_version" {
  type        = string
  description = "Kyverno helm chart version"
}

variable "excluded_namespaces" {
  type        = list(string)
  description = "Service policies excluded namespaces"
}