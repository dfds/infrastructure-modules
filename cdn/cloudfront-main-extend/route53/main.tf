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

module "route53_hosted_zone" {
  source = "../../../_sub/network/route53-zone"  
  deploy = "${var.cf_main_hosted_zone_deploy}"
  dns_zone_name = "${var.cf_main_dns_zone}"
}