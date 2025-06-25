module "iam_github_oidc_provider" {
  source           = "../../_sub/security/iam-github-oidc-provider"
  repositories     = var.iam_github_oidc_repositories
  oidc_role_access = var.iam_github_oidc_policy_json
  oidc_role_name   = var.iam_github_oidc_role_name
  oidc_policy_name = var.iam_github_oidc_policy_name
}
