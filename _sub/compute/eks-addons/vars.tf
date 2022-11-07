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

