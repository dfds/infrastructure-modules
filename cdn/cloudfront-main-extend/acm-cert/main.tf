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

module "cf_domain_cert" {
source =        "../../../_sub/network/acm-certificate-san-simple"
  deploy        = "${var.cf_domain_cert_deploy}"
  domain_name   = "www.${var.cf_main_dns_zone}"
  dns_zone_id = "${length(var.dns_zone_id) == 0 ? data.aws_route53_zone.zone.id : var.dns_zone_id}"
  subject_alternative_names    = ["${var.cf_main_dns_zone}"] #["${var.cdn_domain_name}"]  
}