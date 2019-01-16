resource "azuread_application" "app" {
    name = "${var.name}"
    identifier_uris = "${var.identifier_uris}"
    reply_urls = "${var.reply_urls}"
}

resource "azuread_service_principal" "app" {
    application_id = "${azuread_application.app.application_id}"
}