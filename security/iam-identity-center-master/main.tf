module "iam_identity_center" {
  source = "../../_sub/security/iam-identity-center"

  pca_account_ids = var.pca_account_ids
  private_ca_arns = var.private_ca_arns
}
