module "iam_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 6.2"

  for_each = var.custom_policies
  name     = each.key
  policy   = jsonencode(each.value.policy)
  tags     = var.tags
}

locals {
  policies = merge({ for k, v in module.iam_policy : k => v.arn }, var.existing_policies)
}

# trunk-ignore-all(checkov/CKV_TF_1)
module "iam_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.2"

  name                     = var.role_name
  use_name_prefix          = false
  trust_policy_permissions = var.trust_policy_permissions
  policies                 = local.policies
  enable_github_oidc       = var.enable_github_oidc
  oidc_wildcard_subjects   = var.enable_github_oidc ? var.oidc_wildcard_subjects : []
  tags                     = var.tags
}
