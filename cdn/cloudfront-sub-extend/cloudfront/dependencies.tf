# Find a certificate that is issued
data "aws_acm_certificate" "cf_domain_cert" {
  provider = "aws.acm"

  domain   = "www.${var.cf_main_dns_zone}"
  statuses = ["ISSUED"]
}