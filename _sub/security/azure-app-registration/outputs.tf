output "tenant_id" {
  value = data.azuread_client_config.current.tenant_id
}

output "client_id" {
  value = azuread_application.app.client_id
}

output "application_key" {
  value     = azuread_service_principal_password.key.value
  sensitive = true
}
