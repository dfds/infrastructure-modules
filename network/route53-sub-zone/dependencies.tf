data "aws_route53_zone" "selected" {
  name         = "${var.dns_parent_zone_name}"
  private_zone = false
}