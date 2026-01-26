variable "oidc_client_id_list" {
  description = "List of Client IDs (app ids) that can authenticate to the OIDC provider"
  type        = list(string)
}

variable "oidc_thumbprint_list" {
  description = "Thumbprint of OIDC providers server certificate"
  type        = list(string)
}