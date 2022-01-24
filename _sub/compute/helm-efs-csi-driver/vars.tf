variable "eks_openid_connect_provider_url" {
  type        = string
  description = "The OpenID Connect provider URL for the EKS cluster"
  default     = null
}

variable "chart_version" {
  type        = string
  description = "The Helm chart version to deploy"
}

# Currently only needed for IAM policy. Convert this to inline policy, ditch cluster name from policy name and remove this variable?
variable "cluster_name" {
  type        = string
  description = "The cluster name"
}
