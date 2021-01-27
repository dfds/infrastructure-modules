variable "namespace" {
  type = string
  description = "Namespace in which to install Crossplane"
  default = "crossplane-system"
}

variable "chart_version" {
  type = string
  description = "Specify a version of the Helm chart"
  default = null
}

variable "release_name" {
  type = string
  description = "Name of the chart release"
  default = "crossplane"
}

variable "recreate_pods" {
    type = bool
    description = "Recreate pods on deployment"
    default = true
}

variable "force_update" {
    type = bool
    description = "Force resource updates through replacement"
    default = false
}

variable "crossplane_providers" {
  type = list(string)
  description = "List of Crossplane providers to install"
  default = []
}