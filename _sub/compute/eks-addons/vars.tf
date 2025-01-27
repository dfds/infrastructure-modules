variable "cluster_name" {
  type = string
}

variable "cluster_version" {
  type = string
}

variable "eks_openid_connect_provider_url" {
  type = string
}

variable "kubeproxy_version_override" {
  type    = string
  default = ""
}

variable "coredns_version_override" {
  type    = string
  default = ""
}

variable "vpccni_version_override" {
  type    = string
  default = ""
}

variable "awsebscsidriver_version_override" {
  type    = string
  default = ""
}

variable "awsefscsidriver_version_override" {
  type    = string
  default = ""
}

variable "vpccni_prefix_delegation_enabled" {
  type        = bool
  description = "Whether to enable prefix delegation mode on the VPC CNI addon."
  default     = false
}

variable "most_recent" {
  type        = bool
  default     = false
  description = "Should we use the latest version of an EKS add-on?"
}

variable "efs_fs_id" {
  type    = string
  default = "ID of the EFS file system to use for the EFS CSI StorageClass"
}
