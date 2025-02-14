resource "azuread_application" "app" {
  display_name    = var.name
  identifier_uris = var.identifier_uris
  owners          = [data.azuread_client_config.current.object_id]

  web {
    homepage_url  = var.homepage_url
    redirect_uris = var.redirect_uris
  }

  dynamic "app_role" {
    for_each = var.app_roles
    content {
      allowed_member_types = app_role.value.allowed_member_types
      description          = app_role.value.description
      display_name         = app_role.value.display_name
      enabled              = app_role.value.enabled
      id                   = app_role.value.id
      value                = app_role.value.value
    }
  }

  lifecycle {
    ignore_changes = [
      required_resource_access,
    ]
  }

  group_membership_claims = var.groups_claim

}

resource "azuread_service_principal" "sp" {
  client_id                    = azuread_application.app.client_id
  owners                       = [data.azuread_client_config.current.object_id]
  app_role_assignment_required = var.assignment_is_required
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!@#$%&*-_=+:?"
}

resource "azuread_service_principal_password" "key" {
  service_principal_id = azuread_service_principal.sp.id
}


resource "azuread_application_api_access" "azure_app" {
  count          = length(local.scope_ids) > 0 || length(local.roles_ids) > 0 ? 1 : 0
  application_id = "/applications/${azuread_application.app.object_id}"
  api_client_id  = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]

  role_ids  = local.roles_ids
  scope_ids = local.scope_ids
}
