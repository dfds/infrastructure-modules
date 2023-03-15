variable "chart_version" {
  type        = string
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
  default = { "pod-security.kubernetes.io/audit" = "baseline", "pod-security.kubernetes.io/enforce" = "privileged" }
}
