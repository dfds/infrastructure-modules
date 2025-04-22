data "aws_organizations_organization" "org" {}

module "ou" {
  source    = "../../_sub/security/org-ou"
  name      = var.ou_name
  parent_id = var.parent_id != "" ? var.parent_id : data.aws_organizations_organization.org.roots[0].id
}
