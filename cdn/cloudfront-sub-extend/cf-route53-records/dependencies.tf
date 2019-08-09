data "aws_route53_zone" "zone" {
  name         = "${var.cf_main_dns_zone}."
  private_zone = false
}