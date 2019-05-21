# --------------------------------------------------
# Request certificate
# --------------------------------------------------

# Create the certificate request
resource "aws_acm_certificate" "cert" {
  count                     = "${var.deploy}"
  domain_name               = "${var.domain_name}"
  subject_alternative_names = "${var.core_alias}"
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
    ignore_changes = ["subject_alternative_names"] # workaround to https://github.com/terraform-providers/terraform-provider-aws/issues/8531
  }
}

# --------------------------------------------------
# Gotchas and workaround
# --------------------------------------------------

/*
Gotchas:
- Only values known during the plan phase can be used for "count" - i.e. not anything derived from output of resources
- The element() interpolation can only be used against simple lists - i.e. not lists containing maps, like validation_options does
- Using "[index]" to access element in list, doesn't work with "concat(aws_acm_certificate.cert.*.domain_validation_options, list(list(map("resource_record_name", ""))))"
- Local variables are not consistently calculated, so output from a resource cannot reliably be processed by a local variable - e.g. to select a specific element of a list
- Passing the results via a local file, and read it with "data external" seems to force the local variable to be calculated
- "external" data cannot handle lists (https://github.com/terraform-providers/terraform-provider-external/issues/2)
*/

# Output validation options in JSON format to file
resource "local_file" "validate_json" {
  content  = "${jsonencode(flatten(aws_acm_certificate.cert.*.domain_validation_options))}"
  filename = "${pathexpand("./validate.json")}"
}

/*
- Duplicate external.validate_json
- First: Return one element, matching cert CN
- Second: Return all elements, not matching cert CN
*/


# Read the JSON file back, one instance per element in the JSON array
data "external" "validate_json_workload" {
  count      = "${var.deploy}"
  depends_on = ["local_file.validate_json"]
  program    = ["bash", "${path.module}/element_from_json_array.sh", "${pathexpand("./validate.json")}", "==", "${var.domain_name}", "${count.index}"]
}

data "external" "validate_json_core" {
  count      = "${var.deploy ? length(var.core_alias) : 0}"
  depends_on = ["local_file.validate_json"]
  program    = ["bash", "${path.module}/element_from_json_array.sh", "${pathexpand("./validate.json")}", "!=", "${var.domain_name}", "${count.index}"]
}

# Save the output in variable
locals {
  validate_json_workload = "${data.external.validate_json_workload.*.result}"
  validate_json_core = "${data.external.validate_json_core.*.result}"
}

# --------------------------------------------------
# Validate certificate
# --------------------------------------------------

# Create validation DNS record in the workload DNS zone
resource "aws_route53_record" "workload" {
  count   = "${var.deploy}"
  name    = "${lookup(local.validate_json_workload[0], "resource_record_name")}"
  type    = "${lookup(local.validate_json_workload[0], "resource_record_type")}"
  zone_id = "${local.dns_zone_id}"
  records = ["${lookup(local.validate_json_workload[0], "resource_record_value")}"]
  ttl     = 60
}

# Create validation DNS record(s) in the core DNS zone (alternative names specified)
resource "aws_route53_record" "core" {
  count   = "${var.deploy ? length(var.core_alias) : 0}"
  name    = "${lookup(local.validate_json_core[count.index], "resource_record_name")}"
  type    = "${lookup(local.validate_json_core[count.index], "resource_record_type")}"
  zone_id = "${local.core_dns_zone_id}"
  records = ["${lookup(local.validate_json_core[count.index], "resource_record_value")}"]
  ttl     = 60

  provider = "aws.core"
}

# Validate the certificate using the DNS validation records created
resource "aws_acm_certificate_validation" "cert" {
  count                   = "${var.deploy}"
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${concat(aws_route53_record.workload.*.fqdn, aws_route53_record.core.*.fqdn)}"]
}
