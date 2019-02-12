data "aws_route53_zone" "zone" {
  count        = "${var.deploy}"
  name         = "${var.zone_name}."
  private_zone = false
}
