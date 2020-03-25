variable "deploy" {
  type    = bool
  default = true
}

variable "cluster_name" {
}

variable "blaster_configmap_bucket" {
}

variable "extra_permitted_roles" {
  type = list(string)
  default = []
  description = "Additional role names or ARNs that can be assumed from this namespace through KIAM"
}


variable "kiam_server_role_arn" {
  type        = string
  description = "The role or entity to provide trust for when creating roles to use with annotations in kubernetes"
}

