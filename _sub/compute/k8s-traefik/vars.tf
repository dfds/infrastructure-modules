variable "deploy" {
  default = true
}
variable "cluster_name" {}

variable "deploy_name" {}

variable "namespace" {
  default = "kube-system"
}

variable "image_version" {
}

variable "replicas" {
  default = 2
}

variable "kubeconfig_path" {
  type = "string"
}