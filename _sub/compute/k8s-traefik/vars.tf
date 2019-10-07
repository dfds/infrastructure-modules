variable "deploy" {
  default = true
}
variable "cluster_name" {}

variable "deploy_name" {}

variable "namespace" {
  default = "kube-system"
}

variable "version" {
  default = "1.7.9"
}

variable "replicas" {
  default = 2
}