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

module "aws_route53_cf_redirect_record" {
  source = "../../../_sub/network/route53-alias-record"
  # A record for example.com
  deploy = "${var.cf_route53_records_deploy}"
  zone_id = "${length(var.dns_zone_id) == 0 ? data.aws_route53_zone.zone.id : var.dns_zone_id}"
  record_name = ["${var.cf_main_dns_zone}"]
  record_type = "A"
  alias_target_dns_name = "${var.cf_redirect_distribution_domain_name}" #"${module.aws_cloudfront_redirect.distribution_domain_name}"
  alias_target_zone_id = "${var.cf_redirect_distribution_hosted_zone_id}" #"${module.aws_cloudfront_redirect.distribution_hosted_zone_id}"
}

module "aws_route53_cf_www_record" {
  source = "../../../_sub/network/route53-record"
  # CName record for www.example.com
  deploy = "${var.cf_route53_records_deploy}"  
  zone_id = "${length(var.dns_zone_id) == 0 ? data.aws_route53_zone.zone.id : var.dns_zone_id}"
  record_name = ["www.${var.cf_main_dns_zone}"]
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = "${var.cf_www_distribution_domain_name}" #"${module.aws_cloudfront_www.distribution_domain_name}"  
}