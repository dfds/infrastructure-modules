resource "azuread_app_role_assignment" "this" {
  count               = length(var.role_assignments)
  app_role_id         = var.role_assignments[count.index].app_role_id
  principal_object_id = var.role_assignments[count.index].principal_id
  resource_object_id  = var.role_assignments[count.index].resource_id
}