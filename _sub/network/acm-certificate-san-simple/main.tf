# resource "aws_acm_certificate" "cert" {
#   count = "${var.deploy ? 1 :0}"
#   domain_name       = "${var.domain_name}"
#   subject_alternative_names = "${var.subject_alternative_names}"
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#     ignore_changes = ["subject_alternative_names"] # workaround to https://github.com/terraform-providers/terraform-provider-aws/issues/8531
#   }
# }



# # resource "aws_route53_record" "cert_validation" {
# #   count = "${var.deploy ? local.domain_names :0}"
# #   name    = "${aws_acm_certificate.cert[0].domain_validation_options.0.resource_record_name}"
# #   type    = "${aws_acm_certificate.cert[0].domain_validation_options.0.resource_record_type}"
# #   zone_id = "${var.dns_zone_id}" #"${data.aws_route53_zone.zone[0].id}"
# #   records = ["${aws_acm_certificate.cert[0].domain_validation_options.0.resource_record_value}"]
# #   ttl     = 300
# # }

# # resource "aws_acm_certificate_validation" "cert" {
# #   count = "${var.deploy ? 1 :0}"
# #   certificate_arn         = "${aws_acm_certificate.cert[0].arn}"
# #   validation_record_fqdns = ["${aws_route53_record.cert_validation[0].fqdn}"]
# # }

# resource "aws_route53_record" "cert_validation" {
#   count = "${length(local.domain_names)}"
#   name = "${lookup(aws_acm_certificate.cert[0].domain_validation_options, "resource_record_name")}"
#   type = "${lookup(aws_acm_certificate.cert[0].domain_validation_options, "resource_record_type")}"
#   zone_id = "${var.dns_zone_id}"
#   records = ["${lookup(aws_acm_certificate.cert[0].domain_validation_options, "resource_record_value")}"]
#   ttl = 60
# }

# resource "aws_acm_certificate_validation" "cert" {
#   count = "${length(local.domain_names)}"
#   certificate_arn = "${aws_acm_certificate.cert[0].arn}"
#   validation_record_fqdns = ["${aws_route53_record.cert_validation[count.index].fqdn}"]
# }

locals {
  # domain_names = ["samdi2.dfds.cloud", "www.samdi2.dfds.cloud"]#  "${concat([var.domain_name], var.subject_alternative_names)}"
  domain_names = "${concat([var.domain_name], var.subject_alternative_names)}"
}


resource "aws_acm_certificate" "main" {
  count = "${var.deploy ? 1 :0}"
  domain_name = "${local.domain_names[0]}"
  subject_alternative_names = "${slice(local.domain_names, 1, length(local.domain_names))}"
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
    ignore_changes = ["subject_alternative_names"] # workaround to https://github.com/terraform-providers/terraform-provider-aws/issues/8531
  }
}

resource "aws_route53_record" "validation" {
  count = "${var.deploy ? length(local.domain_names) : 0}"
  name = "${lookup(aws_acm_certificate.main[0].domain_validation_options[count.index], "resource_record_name")}"
  type = "${lookup(aws_acm_certificate.main[0].domain_validation_options[count.index], "resource_record_type")}"
  zone_id ="${var.dns_zone_id}" #" "${var.zone_id}"
  records = ["${lookup(aws_acm_certificate.main[0].domain_validation_options[count.index], "resource_record_value")}"]
  ttl = 60
}

resource "aws_acm_certificate_validation" "main" {
  count = "${var.deploy ? 1 :0}"
  certificate_arn = "${aws_acm_certificate.main[0].arn}"
  validation_record_fqdns = "${aws_route53_record.validation.*.fqdn}"
}