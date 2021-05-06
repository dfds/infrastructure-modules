output "application_id" {
  value = azuread_application.app.application_id
}

output "application_key" {
  value     = azuread_service_principal_password.key.value
  sensitive = true
}