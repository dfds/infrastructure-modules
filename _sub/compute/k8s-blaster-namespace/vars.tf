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
  description = "Additional role ARNs that can be assumed from this namespace through KIAM"
  validation {
    condition = can([for role in var.extra_permitted_roles : regex("^arn:aws:iam::", role)])
    error_message = "The list values (if defined) must contain full roles ARNs."
  }
}


variable "kiam_server_role_arn" {
  type        = string
  description = "The role or entity to provide trust for when creating roles to use with annotations in kubernetes"
}

