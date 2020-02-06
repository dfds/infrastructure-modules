resource "aws_route53_record" "ns" {
  # This will create the record of type NS that enables a sub domain to be queried
  zone_id = var.dns_zone_id
  name    = var.dns_child_zone_name
  type    = "NS"
  ttl     = "300"

  records = var.dns_zone_ns
}

