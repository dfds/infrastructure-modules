data "aws_route53_zone" "parent" {
  name         = "${var.dns_parent_zone_name}"
  private_zone = false
}