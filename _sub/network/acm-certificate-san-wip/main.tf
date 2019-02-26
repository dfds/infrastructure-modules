# --------------------------------------------------
# Providers - to be removed
# --------------------------------------------------

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.40"

  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.40"
  alias   = "core"
}


# --------------------------------------------------
# Module
# --------------------------------------------------

resource "aws_acm_certificate" "cert" {
  count                     = "${var.deploy}"
  domain_name               = "${var.domain_name}"
  subject_alternative_names = "${var.core_alt_names}"
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "workload" {
  count   = "${var.deploy}"
  name    = "${lookup(local.validate_json[0], "resource_record_name")}"
  type    = "${lookup(local.validate_json[0], "resource_record_type")}"
  zone_id = "${local.dns_zone_id}"
  records = ["${lookup(local.validate_json[0], "resource_record_value")}"]
  ttl     = 60
}


# Gotchas:
# - Only values known during the plan phase can be used for "count" - i.e. not anything derived from output of resources
# - The element() interpoloation can only be used against simple lists - i.e. not lists containing maps, like validation_options does
# - Using "[index]" to access element in list, doesn't work with "concat(aws_acm_certificate.cert.*.domain_validation_options, list(list(map("resource_record_name", ""))))"
# - Local variables are not consistently calculated, so output from a resource cannot reliably be processed by a local variable - e.g. to select a specific element of a list
# - Passing the results via a local file, and read it with "data external" seems to force the local variable to be calculated
# - "external" data cannot handle lists (https://github.com/terraform-providers/terraform-provider-external/issues/2)


# Output validation options in JSON format to file
resource "local_file" "validate_json" {
  content = "${jsonencode(flatten(aws_acm_certificate.cert.*.domain_validation_options))}"
  filename = "${pathexpand("./validate.json")}"
}

# For each validation option to process, parse the JSON file using JQ and get the map for the specified index number
data "external" "validate_json" {
  count = "${var.deploy ? length(var.core_alt_names) + 1 : 0}"
  depends_on = ["local_file.validate_json"]
  program = ["bash", "element_from_json_array.sh", "${pathexpand("./validate.json")}", "${count.index}"]
}

locals {
  # validate_splat = "${flatten(aws_acm_certificate.cert.*.domain_validation_options)}"
  # validate_json = "${concat(data.external.validate_json.*.result, list(map("domain_name", "", "resource_record_name", "", "resource_record_type", "", "resource_record_value", "")))}"
  validate_json = "${data.external.validate_json.*.result}"
}


output "validate_json" {
  value = "${local.validate_json}"
}


resource "aws_route53_record" "core" {
  count   = "${var.deploy ? length(var.core_alt_names) : 0}"
  name    = "${lookup(local.validate_json[count.index + 1], "resource_record_name")}"
  type    = "${lookup(local.validate_json[count.index + 1], "resource_record_type")}"
  zone_id = "${local.core_dns_zone_id}"
  records = ["${lookup(local.validate_json[count.index + 1], "resource_record_value")}"]
  ttl     = 60

  provider = "aws.core"
}

/*
validate_list is not updated before adding core records, so cannot be used for count or to address properties

*/

resource "aws_acm_certificate_validation" "cert" {
  count = "${var.deploy}"
  certificate_arn         = "${aws_acm_certificate.cert.arn}"
  validation_record_fqdns = ["${concat(aws_route53_record.workload.*.fqdn, aws_route53_record.core.*.fqdn)}"]
}


# output "out1" {
#   value = "${length(flatten(concat(aws_acm_certificate.cert.*.domain_validation_options, list(list(""))))) - 1}"
# }

# output "out2" {
#   value = "${length(flatten(aws_acm_certificate.cert.*.domain_validation_options))}"
# }

# output "out3" {
#   value = "${flatten(concat(aws_acm_certificate.cert.*.domain_validation_options, list(list(""))))}"
# }

# output "out4" {
#   value = "${flatten(aws_acm_certificate.cert.*.domain_validation_options)}"
# }

# output "out6" {
#   value = "${length(var.core_alt_names)}"
# }