data "aws_organizations_organization" "org" {}

data "aws_organizations_organizational_unit_descendant_organizational_units" "ous" {
  parent_id = data.aws_organizations_organization.org.roots[0].id
}

locals {
  organizational_unit_ids = flatten([ for ou_name in var.ous_list : [ for ou in data.aws_organizations_organizational_unit_descendant_organizational_units.ous.children : ou.id if ou.name == ou_name ]])
  aad_tenant_id = "33e01921-4d64-4f8c-a055-5bdaffd5e33d"
}
