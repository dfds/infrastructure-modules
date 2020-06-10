variable "deploy" {
  type    = bool
  default = true
}

variable "cluster_name" {
}

variable "deploy_name" {
}

variable "namespace" {
  default = "kube-system"
}

variable "image_version" {
}

variable "replicas" {
}

variable "priority_class" {
  description = "Name of the Kubernetes priority class pods should use"
  type = string
}
