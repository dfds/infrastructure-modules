variable "kubeconfig_path" {
  type        = string
  description = "The path to the kubeconfig file."
  default     = null
}

variable "namespace" {
  type        = string
  description = "The namespace that should be annotated."
}

variable "annotations" {
  type        = map
  description = "One or more annotations that should be added to the namespace."
  default     = {}
}
