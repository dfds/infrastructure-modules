# --------------------------------------------------
# Capability OU
# --------------------------------------------------

module "capability_ou" {
  source    = "../../_sub/security/org-ou"
  name      = var.capability_ou_name
  parent_id = data.aws_organizations_organization.org.roots[0].id
}
