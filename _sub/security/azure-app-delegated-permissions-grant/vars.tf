variable "service_principal_object_id" {
  type        = string
  description = "The object ID of the service principal to grant delegated permissions to."
}

variable "api_scopes" {
  type        = list(string)
  description = <<EOF
    scopes is a list of api permissions/scopes to assign to the application and grant admin consent. Example: [\"email\"]"
    Default value is ["email", "openid", "profile"] which are used for SSO with Azure AD.
  EOF
  default     = ["email", "openid", "profile"]
}
