# TODO: This is V2 of the org-policy sub module that needs to be kept a bit more for legacy reasons
resource "aws_organizations_policy" "policy" {
  name        = var.name
  description = var.description
  content     = var.policy
}

locals {
  attach_targets = toset(var.attach_targets)
}

resource "aws_organizations_policy_attachment" "attach" {
  for_each  = local.attach_targets
  policy_id = aws_organizations_policy.policy.id
  target_id = each.key
}

