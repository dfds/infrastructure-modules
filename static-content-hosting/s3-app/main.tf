terraform {
  backend          "s3"             {}
  required_version = "~> 0.12.2"
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.15"  # from 2.11 Minimum required 2.14

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

module "s3_app" { 
  source       = "../../_sub/storage/s3-app-bucket"
  s3_bucket = var.s3_app_bucket
  allowed_iam_arns = var.s3_app_allowed_iam_arns
  enable_versioning = true
  enable_destroy = true
  bucket_canned_acl = "private"
}
