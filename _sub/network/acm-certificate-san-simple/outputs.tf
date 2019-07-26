output "certificate_arn" {
  value = "${element(concat(aws_acm_certificate_validation.main.*.certificate_arn, list("")), 0)}"
}


# output "aws_route53_records" {
#   value = "${aws_route53_record.validation.*.name}"
# }


# output "aws_fqdns" {
#   value = "${aws_route53_record.validation.*.fqdn}"
# }