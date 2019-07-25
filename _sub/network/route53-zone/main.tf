resource "aws_route53_zone" "dnszone" {
  # This will create a route 53 DNS zone with the hostname provided
  count = "${var.deploy}"
  name  = "${var.dns_zone_name}"
}