resource "aws_route53_zone" "dnszone" {
  # This will create a route 53 DNS zone with the hostname provided
  name = var.dns_zone_name
}

