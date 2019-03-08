resource "random_string" "password" {
  count            = "${var.deploy}"
  special          = "${var.special_character_enabled}"
  override_special = "{}[]!"
  length           = 24
}