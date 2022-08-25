variable "deploy" {
  type    = bool
  default = true
}

variable "cluster_name" {
}

variable "blaster_configmap_bucket" {
}

variable "oidc_issuer" {
  type        = string
  description = "Used for iam policy oidc trust"
  validation {
    condition     = substr(var.oidc_issuer, 0, 8) != "https://"
    error_message = "Oidc_issuer may not contain https:// in the start of the variable."
  }
}

variable "extra_permitted_roles" {
  type        = list(string)
  default     = []
  description = "Additional role ARNs that can be assumed from this namespace through KIAM"
  validation {
    condition = var.extra_permitted_roles == [] ? true : (
      can([for role in var.extra_permitted_roles : regex("^arn:aws:iam::", role)])
    )
    error_message = "The list values (if defined) must contain full roles ARNs."
  }
}


# variable "kiam_server_role_arn" {
#   type        = string
#   description = "The role or entity to provide trust for when creating roles to use with annotations in kubernetes"
# }

