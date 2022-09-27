# --------------------------------------------------
# Init
# --------------------------------------------------

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
  source    = "../../_sub/storage/s3-bucket"
  deploy    = length(var.eks_public_s3_bucket) >= 1 ? true : false
  s3_bucket = var.eks_public_s3_bucket
  acl       = "public-read"
  enable_server_side_encryption = var.enable_server_side_encryption
}
