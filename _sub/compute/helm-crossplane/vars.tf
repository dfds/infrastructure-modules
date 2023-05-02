variable "namespace" {
  type        = string
  description = "Namespace in which to install Crossplane"
}

variable "namespace_labels" {
  type    = map(any)
  default = {}
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

variable "devel" {
  type        = bool
  description = "Allow use of development versions of Crossplane"
}

variable "crossplane_providers" {
  type        = list(string)
  description = "List of Crossplane providers to install"
}

variable "crossplane_admin_service_accounts" {
  type = list(object({
    serviceaccount = string
    namespace      = string
  }))
  description = "List of service account objects that should have crossplane-admin access"
}

variable "crossplane_edit_service_accounts" {
  type = list(object({
    serviceaccount = string
    namespace      = string
  }))
  description = "List of service account objects that should have crossplane-edit access"
}

variable "crossplane_view_service_accounts" {
  type = list(object({
    serviceaccount = string
    namespace      = string
  }))
  description = "List of service account objects that should have crossplane-view access"
}

variable "crossplane_metrics_enabled" {
  type        = bool
  description = "Enable crossplane metrics"
}

variable "crossplane_aws_iam_role_name" {
  type        = string
  description = "Name for the IAM role name to create for use by the AWS provider"
}

variable "eks_openid_connect_provider_url" {
  type        = string
  description = "The OpenID Connect provider URL for the EKS cluster"
  default     = null
}
