output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}

output "client_id" {
  value = azuread_application.app.client_id
}

output "application_object_id" {
  value = azuread_application.app.object_id

}

output "application_key" {
  value     = azuread_service_principal_password.key.value
  sensitive = true
}

output "oauth_2_authorization_endpoint" {
  value = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/oauth2/v2.0/authorize"

}
output "oauth_2_token_endpoint" {
  value = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/oauth2/v2.0/token"

}

output "service_principal_id" {
  value = azuread_service_principal.sp.object_id
}