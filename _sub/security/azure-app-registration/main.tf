resource "azuread_application" "app" {
  display_name    = var.name
  identifier_uris = var.identifier_uris
  web {
    homepage_url    = var.homepage_url
    redirect_uris      = var.redirect_uris
  }
}

resource "azuread_service_principal" "sp" {
  application_id = azuread_application.app.application_id
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!@#$%&*-_=+:?"
}

resource "azuread_service_principal_password" "key" {
  service_principal_id = azuread_service_principal.sp.id
}
