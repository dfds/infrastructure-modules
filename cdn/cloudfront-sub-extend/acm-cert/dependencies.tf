data "aws_route53_zone" "zone" {  
  name         = "${var.cf_dns_zone}."
  private_zone = false
}