# data "aws_route53_zone" "zone" {
#   count        = "${var.deploy}"
#   name         = "${var.dns_zone_name}."
#   private_zone = false
# }
