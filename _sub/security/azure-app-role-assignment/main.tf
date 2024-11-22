
resource "azuread_app_role_assignment" "this" {
  for_each = { for x in var.role_assignments : x.app_role_id => x }


  app_role_id  = each.value.app_role_id
  principal_object_id = each.value.principal_id
  resource_object_id  = each.value.resource_id
}
