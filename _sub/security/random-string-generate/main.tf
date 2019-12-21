resource "random_string" "password" {
  count            = var.deploy ? 1 : 0
  special          = var.special_character_enabled
  override_special = "{}[]!"
  length           = 24
}

