variable "chart_version" {
  type        = string
  description = "Nvidia device plugin helm chart version"
  default     = null
}

variable "namespace" {
  type        = string
  description = "Nvidia device plugin namespace"
  default     = null
}

variable "create_namespace" {
  type        = bool
  description = "Whether to create a namespace with helm"
  default     = false
}

variable "tolerations" {
  type = list(object({
    key      = string
    operator = string
    value    = optional(string)
    effect   = string
  }))
  description = "A list of tolerations to apply to the nvidia device plugin deployment"
  default     = []
}

variable "affinity" {
  type = list(object({
    key      = string
    operator = string
    values   = list(string)
  }))
  description = "A list of affinities to apply to the nvidia device plugin deployment"
}
