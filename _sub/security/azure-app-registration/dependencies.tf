data "azuread_client_config" "current" {}

data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
}

locals {
  scope_ids = var.api_permissions != null ? [
    for scope in var.api_permissions.scopes : data.azuread_service_principal.msgraph.oauth2_permission_scope_ids[scope]
  ] : []
  roles_ids = var.api_permissions != null ? [
    for role in var.api_permissions.roles : data.azuread_service_principal.msgraph.app_role_ids[role]
  ] : []

  azuread_application_owner_ids = concat([data.azuread_client_config.current.object_id], var.additional_owner_ids)
}
