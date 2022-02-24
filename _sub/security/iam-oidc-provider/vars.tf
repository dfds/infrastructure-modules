variable "eks_openid_connect_provider_url" {
  type        = string
  description = "The OpenID Connect provider URL for the EKS cluster"
  default     = null
}

variable "eks_cluster_name" {
  type        = string
  description = "The name of the EKS cluster"
  default     = null
}
