resource "aws_route53_record" "record" {
  zone_id = "${data.aws_route53_zone.zone.id}"
  name    = "${var.record_name}"
  type    = "${var.record_type}"
  ttl     = "${var.record_ttl}"
  records = ["${var.record_value}"]
}