variable "eks_openid_connect_provider_url" {
  type        = string
  description = "The OpenID Connect provider URL for the EKS cluster"
  default     = null
}

variable "kubeconfig_path" {
  type        = string
  description = "The path to the kubeconfig file"
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

variable "csi_ebs_serviceaccount_name" {
  type        = string
  description = "The name of the Service Account used by the CSI EBS Driver."
  default     = "ebs-csi-controller-sa"
}

variable "csi_ebs_serviceaccount_namespace" {
  type        = string
  description = "The namespace  where the Service Account used by the CSI EBS Driver is located."
  default     = "kube-system"
}
