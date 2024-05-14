data "azuread_client_config" "current" {}

data "azuread_user" "owner" {
  for_each            = toset(var.owners)
  user_principal_name = each.value
}

locals {
  owners = concat([data.azuread_client_config.current.object_id], [for user in data.azuread_user.owner : user.object_id])
}

resource "azuread_group" "this" {
  display_name     = var.display_name
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]
  administrative_unit_ids = var.administrative_unit_ids
#  prevent_duplicate_names = true
}


