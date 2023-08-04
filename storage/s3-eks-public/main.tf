module "s3_bucket" {
  source                        = "../../_sub/storage/s3-bucket"
  deploy                        = length(var.eks_public_s3_bucket) >= 1 ? true : false
  s3_bucket                     = var.eks_public_s3_bucket
  acl                           = var.eks_is_sandbox ? "private" : var.acl
  enable_server_side_encryption = var.enable_server_side_encryption
  additional_tags               = var.additional_tags
}
