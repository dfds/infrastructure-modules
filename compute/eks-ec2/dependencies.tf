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
  count        = "${signum(length(var.traefik_alb_auth_core_alias))}"
  name         = "${local.core_dns_zone_name}."
  private_zone = false
  provider     = "aws.core"
}

# Get DNS zone IDs
locals {
  workload_dns_zone_id = "${element(concat(data.aws_route53_zone.workload.*.zone_id, list("")), 0)}"
  core_dns_zone_id     = "${element(concat(data.aws_route53_zone.core.*.zone_id, list("")), 0)}"
}

# Generate Traefik authenticated ALB app registration reply URLs
locals {
  traefik_alb_auth_endpoints                = "${concat(list("internal.${local.eks_fqdn}"), var.traefik_alb_auth_core_alias)}"
  traefik_alb_auth_appreg_reply_join        = "^${join("$,^", local.traefik_alb_auth_endpoints)}$"
  traefik_alb_auth_appreg_reply_replace_pre = "${replace(local.traefik_alb_auth_appreg_reply_join, "^", "https://")}"
  traefik_alb_auth_appreg_reply_replace_end = "${replace(local.traefik_alb_auth_appreg_reply_replace_pre, "$", "/oauth2/idpresponse")}"
  traefik_alb_auth_appreg_reply_urls        = "${split(",", local.traefik_alb_auth_appreg_reply_replace_end)}"
}  
