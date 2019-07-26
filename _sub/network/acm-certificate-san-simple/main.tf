resource "aws_acm_certificate" "cert" {
  count = "${var.deploy ? 1 :0}"
  domain_name       = "${var.domain_name}"
  subject_alternative_names = "${var.subject_alternative_names}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
    ignore_changes = ["subject_alternative_names"] # workaround to https://github.com/terraform-providers/terraform-provider-aws/issues/8531
  }
}

locals {
  domain_names = "${concat([var.domain_name],var.subject_alternative_names)}"
}


# resource "aws_route53_record" "cert_validation" {
#   count = "${var.deploy ? local.domain_names :0}"
#   name    = "${aws_acm_certificate.cert[0].domain_validation_options.0.resource_record_name}"
#   type    = "${aws_acm_certificate.cert[0].domain_validation_options.0.resource_record_type}"
#   zone_id = "${var.dns_zone_id}" #"${data.aws_route53_zone.zone[0].id}"
#   records = ["${aws_acm_certificate.cert[0].domain_validation_options.0.resource_record_value}"]
#   ttl     = 300
# }

# resource "aws_acm_certificate_validation" "cert" {
#   count = "${var.deploy ? 1 :0}"
#   certificate_arn         = "${aws_acm_certificate.cert[0].arn}"
#   validation_record_fqdns = ["${aws_route53_record.cert_validation[0].fqdn}"]
# }

resource "aws_route53_record" "cert_validation" {
  count = "${length(local.domain_names)}"
  name = "${lookup(aws_acm_certificate.cert[count.index].domain_validation_options, "resource_record_name")}"
  type = "${lookup(aws_acm_certificate.cert[count.index].domain_validation_options, "resource_record_type")}"
  zone_id = "${var.dns_zone_id}"
  records = ["${lookup(aws_acm_certificate.cert[count.index].domain_validation_options, "resource_record_value")}"]
  ttl = 60
}

resource "aws_acm_certificate_validation" "cert" {
  certificate_arn = "${aws_acm_certificate.cert[count.index].arn}"
  validation_record_fqdns = ["${aws_route53_record.cert_validation.*.fqdn}"]
}