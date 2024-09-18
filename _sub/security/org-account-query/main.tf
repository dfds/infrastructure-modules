data "aws_organizations_organizational_unit_child_accounts" "this" {
  parent_id = var.ou_id
}
