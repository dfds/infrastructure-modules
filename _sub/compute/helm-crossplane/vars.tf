variable "namespace" {
  type        = string
  description = "Namespace in which to install Crossplane"
}

variable "chart_version" {
  type        = string
  description = "Specify a version of the Helm chart"
}

variable "release_name" {
  type        = string
  description = "Name of the chart release"
}

variable "recreate_pods" {
  type        = bool
  description = "Recreate pods on deployment"
}

variable "force_update" {
  type        = bool
  description = "Force resource updates through replacement"
}

variable "crossplane_providers" {
  type        = list(string)
  description = "List of Crossplane providers to install"
}
