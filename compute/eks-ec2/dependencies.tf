# Generate EKS fully-qualified domain name
locals {
  eks_fqdn = "${var.eks_cluster_name}.${var.workload_dns_zone_name}"
}

# Determine parent DNS zone name
locals {
  workload_dns_zone_list = "${split(".", var.workload_dns_zone_name)}"
  core_dns_zone_list     = "${slice(local.workload_dns_zone_list, 1, length(local.workload_dns_zone_list))}"
  core_dns_zone_name     = "${join(".", local.core_dns_zone_list)}"
}

data "aws_route53_zone" "workload" {
  name         = "${var.workload_dns_zone_name}."
  private_zone = false
}

data "aws_route53_zone" "core" {
  count        = "${signum(length(var.traefik_alb_core_alias))}"
  name         = "${local.core_dns_zone_name}."
  private_zone = false
  provider     = "aws.core"
}

# Get DNS zone IDs
locals {
  workload_dns_zone_id = "${element(concat(data.aws_route53_zone.workload.*.zone_id, list("")), 0)}"
  core_dns_zone_id     = "${element(concat(data.aws_route53_zone.core.*.zone_id, list("")), 0)}"
}
