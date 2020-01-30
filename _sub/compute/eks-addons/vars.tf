variable "cluster_version" {
  type = string
}

variable "kubeconfig_path" {
  type    = string
  default = null
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
