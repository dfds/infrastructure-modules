resource "aws_organizations_policy" "policy" {
  name        = var.name
  description = var.description
  content     = var.policy
}
