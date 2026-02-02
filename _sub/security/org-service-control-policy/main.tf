# TODO: This is V2 of the org-policy sub module that needs to be kept a bit more for legacy reasons
resource "aws_organizations_policy" "policy" {
  name        = var.name
  description = var.description
  content     = var.policy

  lifecycle {
    precondition {
      condition = length(replace(replace(var.policy, " ", ""), "\n", "")) < 6144
      error_message = "Length of the policy is more than 6144 symbols, current length is: ${length(replace(replace(var.policy, " ", ""), "\n", ""))}"
    }
  }
}

locals {
  attach_targets = toset(var.attach_targets)
}

resource "aws_organizations_policy_attachment" "attach" {
  for_each  = local.attach_targets
  policy_id = aws_organizations_policy.policy.id
  target_id = each.key
}
