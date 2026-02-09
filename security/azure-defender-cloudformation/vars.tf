variable "aws_region" {
  type = string
}

variable "aws_assume_role_arn" {
  type = string
}

variable "client_tenant" {
  description = "Client tenant id"
  type        = string
}

variable "oidc_client_id" {
  description = "Client ID (app id) that can authenticate to the OIDC provider"
  type        = string
}

variable "oidc_thumbprint_list" {
  description = "Thumbprint of OIDC providers server certificate"
  type        = list(string)
}

variable "ous_list" {
  description = "A list of the OUs names"
  type        = list(string)
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to all the resources deployed by the module"
  default     = {}
}

