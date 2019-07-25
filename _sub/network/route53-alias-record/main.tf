resource "aws_route53_record" "record" {
  count   = "${var.deploy ? length(var.record_name) : 0}"
  zone_id = "${var.zone_id}"
  name    = "${var.record_name[count.index]}"
  type    = "${var.record_type}"
  # records = ["${var.record_value}"]

  alias {
    name                   = "${var.alias_target_dns_name}"
    zone_id                = "${var.alias_target_zone_id}"
    evaluate_target_health = false
  }
}
