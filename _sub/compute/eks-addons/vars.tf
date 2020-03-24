variable "cluster_version" {
  type = string
}

# https://discuss.hashicorp.com/t/tips-howto-implement-module-depends-on-emulation/2305/2
variable "module_depends_on" {
  type    = any
  default = null
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
