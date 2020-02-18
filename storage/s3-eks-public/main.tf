# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend "s3" {
  }
  # required_version = "~> 0.11.7"
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.43"

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

module "s3_bucket" {
  source    = "../../_sub/storage/s3-bucket"
  deploy    = length(var.eks_public_s3_bucket) >= 1 ? true : false
  s3_bucket = var.eks_public_s3_bucket
  acl       = "public-read"
}
