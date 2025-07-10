data "aws_organizations_organizational_unit_child_accounts" "this" {
  parent_id = var.ou_id
}

data "aws_organizations_organization" "org" {}

data "aws_organizations_organizational_unit_descendant_organizational_units" "ous" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
}
