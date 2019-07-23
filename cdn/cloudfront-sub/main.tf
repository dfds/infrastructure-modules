# --------------------------------------------------
# Init
# --------------------------------------------------

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

module "aws_cloudfront" {
  source       = "../../_sub/cdn/cloudfront"
  cdn_origins = var.cdn_origins
  acm_certificate_arn = var.acm_certificate_arn  
  cdn_comment = var.cdn_comment  
  aliases = "${var.cdn_domain_name == "" ? [] : [var.cdn_domain_name]}"
}