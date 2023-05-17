# --------------------------------------------------
# Init
# --------------------------------------------------

# Despite the main module name, it should only have public-read for production.
# It is only for history reasons and an active integration with a 3rd party system
# that "public-read" is still the default value for the ACL.
# It is best practice to have a private ACL on S3 buckets.
# Hence it should be set to private for most cluster deployments.

terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

module "s3_bucket" {
  source                        = "../../_sub/storage/s3-bucket"
  deploy                        = length(var.eks_public_s3_bucket) >= 1 ? true : false
  s3_bucket                     = var.eks_public_s3_bucket
  acl                           = var.eks_is_sandbox ? "private" : var.acl
  enable_server_side_encryption = var.enable_server_side_encryption
  additional_tags               = var.additional_tags
}
