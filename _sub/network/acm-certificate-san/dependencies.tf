# Determine parent DNS zone name
locals {
  dns_zone_list      = "${split(".", var.dns_zone_name)}"
  core_dns_zone_list = "${slice(local.dns_zone_list, 1, length(local.dns_zone_list))}"
  core_dns_zone_name = "${join(".", local.core_dns_zone_list)}"
}

# Read workload DNS zone
data "aws_route53_zone" "workload" {
  count        = "${var.deploy}"
  name         = "${var.dns_zone_name}."
  private_zone = false
}

# Read core DNS zone
data "aws_route53_zone" "core" {
  count        = "${var.deploy && length(var.core_alt_names) >= 1 ? 1 : 0}"
  name         = "${local.core_dns_zone_name}."
  private_zone = false
  provider     = "aws.core"
}

# Get DNS zone IDs
locals {
  dns_zone_id      = "${element(concat(data.aws_route53_zone.workload.*.zone_id, list("")), 0)}"
  core_dns_zone_id = "${element(concat(data.aws_route53_zone.core.*.zone_id, list("")), 0)}"
}
