resource "aws_organizations_organizational_unit" "ou" {
  name      = var.name
  parent_id = var.parent_id
}
