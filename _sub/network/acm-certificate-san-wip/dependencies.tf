# locals {
  # Resolve validation records
  # validate_splat = "${concat(aws_acm_certificate.cert.*.domain_validation_options, list(list("")))}"
  # validate_splat = "${flatten(concat(aws_acm_certificate.cert.*.domain_validation_options, list(list(map("resource_record_name", "")))))}"
  # validate_splat = "${concat(aws_acm_certificate.cert.*.domain_validation_options, list(list(map("resource_record_name", ""))))}"
  # validate_splat = "${flatten(aws_acm_certificate.cert.*.domain_validation_options)}"
  # validate_null = "${list("")}"
  # validate_json = "${jsonencode(aws_acm_certificate.cert.*.domain_validation_options)}"

  # validate_list  = "${local.validate_splat[0]}"
# }

locals {
  # Determine parent DNS zone name
  dns_zone_list      = "${split(".", var.dns_zone_name)}"
  core_dns_zone_list = "${slice(local.dns_zone_list, 1, length(local.dns_zone_list))}"
  core_dns_zone_name = "${join(".", local.core_dns_zone_list)}"
}

data "aws_route53_zone" "workload" {
  count        = "${var.deploy}"
  name         = "${var.dns_zone_name}."
  private_zone = false
}

data "aws_route53_zone" "core" {
  count        = "${var.deploy && length(var.core_alt_names) >= 1 ? 1 : 0}"
  name         = "${local.core_dns_zone_name}."
  private_zone = false

  provider = "aws.core"
}

locals {
  # Get DNS zone IDs
  dns_zone_id      = "${element(concat(data.aws_route53_zone.workload.*.zone_id, list("")), 0)}"
  core_dns_zone_id = "${element(concat(data.aws_route53_zone.core.*.zone_id, list("")), 0)}"
}
