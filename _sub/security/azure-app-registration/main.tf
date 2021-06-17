resource "azuread_application" "app" {
  display_name    = var.name
  homepage_url    = var.homepage
  identifier_uris = var.identifier_uris
  reply_urls      = var.reply_urls
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
  end_date_relative    = "87660h" # 87660h = 10y
  value                = random_password.password.result
}
