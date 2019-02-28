provider "aws" {
  version = "~> 1.60.0"
  region  = "${var.aws_region}"
}

module "route53_zone" {
  source        = "../..//network/route53-zone"
  dns_zone_name = "${var.dns_zone_name}"
}
