variable "deploy" {
  default = true
}

variable "cluster_name" {
}

variable "blaster_configmap_bucket" {
}

variable "kiam_server_role_arn" {
  type        = string
  description = "The role or entity to provide trust for when creating roles to use with annotations in kubernetes"
}

