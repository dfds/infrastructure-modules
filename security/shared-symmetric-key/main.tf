module "shared_symmetric_key" {
  source        = "../../_sub/security/kms-key"
  key_alias     = var.key_alias
  description   = "Shared symmetric key for encrypting data at rest"
  key_user_arns = var.key_user_arns
  tags          = var.tags
}
