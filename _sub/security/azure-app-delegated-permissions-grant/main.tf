resource "azuread_service_principal_delegated_permission_grant" "this" {
  service_principal_object_id          = var.service_principal_object_id
  resource_service_principal_object_id = data.azuread_service_principal.msgraph.object_id
  claim_values                         = var.api_scopes
}