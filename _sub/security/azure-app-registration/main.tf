resource "azuread_application" "app" {
  display_name    = var.name
  identifier_uris = var.identifier_uris
  owners          = [data.azuread_client_config.current.object_id]

  web {
    homepage_url  = var.homepage_url
    redirect_uris = var.redirect_uris
  }
}

resource "azuread_service_principal" "sp" {
  client_id = azuread_application.app.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!@#$%&*-_=+:?"
}

resource "azuread_service_principal_password" "key" {
  service_principal_id = azuread_service_principal.sp.id
}
