resource "aws_organizations_policy" "policy" {
  name        = var.name
  description = var.description
  content     = var.policy
}

resource "aws_organizations_policy_attachment" "attach" {
  count     = var.attach_target_id != "" ? 1 : 0
  policy_id = aws_organizations_policy.policy.id
  target_id = var.attach_target_id
}

