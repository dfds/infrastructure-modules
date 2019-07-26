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

## TODO: put into own folder
module "aws_route53_cf_redirect_record" {
  source = "../../_sub/network/route53-alias-record"
  # A record for dfds-ex.com
  deploy = "${var.cf_route53_records_deploy}"
  zone_id = "${length(var.dns_zone_id) == 0 ? data.aws_route53_zone.zone.id : var.dns_zone_id}"
  record_name = ["${var.cf_main_dns_zone}"]
  record_type = "A"
  alias_target_dns_name = "${module.aws_cloudfront_redirect.distribution_domain_name}"
  alias_target_zone_id = "${module.aws_cloudfront_redirect.distribution_hosted_zone_id}"
}

module "aws_route53_cf_www_record" {
  source = "../../_sub/network/route53-record"
  # CName record for www
  deploy = "${var.cf_route53_records_deploy}"  
  zone_id = "${length(var.dns_zone_id) == 0 ? data.aws_route53_zone.zone.id : var.dns_zone_id}"
  record_name = ["www.${var.cf_main_dns_zone}"]
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = "${module.aws_cloudfront_www.distribution_domain_name}"  
}

data "aws_route53_zone" "zone" {  # put it back as dependency for module route53-record
  name         = "${var.cf_main_dns_zone}."
  private_zone = false
}
