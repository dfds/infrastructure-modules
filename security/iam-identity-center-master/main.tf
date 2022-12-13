provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
  }
}

module "iam_identity_center" {
  source                            = "../../_sub/security/iam-identity-center"
}