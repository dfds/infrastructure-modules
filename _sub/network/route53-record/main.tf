resource "aws_route53_record" "record" {
  count   = var.deploy ? length(var.record_name) : 0
  zone_id = var.zone_id
  name    = var.record_name[count.index]
  type    = var.record_type
  ttl     = var.record_ttl
  records = [var.record_value]
}

