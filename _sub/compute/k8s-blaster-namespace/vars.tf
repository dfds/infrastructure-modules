variable "deploy" {
  type    = bool
  default = true
}

variable "cluster_name" {
  type = string
}

variable "blaster_configmap_bucket" {
  type = string
}

variable "oidc_issuer" {
  type        = string
  description = "Used for iam policy oidc trust"
  validation {
    condition     = substr(var.oidc_issuer, 0, 8) != "https://"
    error_message = "Oidc_issuer may not contain https:// in the start of the variable."
  }
}

