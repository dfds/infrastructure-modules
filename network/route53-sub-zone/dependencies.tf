locals {
  dns_zone_list        = split(".", var.dns_zone_name)
  parent_dns_zone_list = slice(local.dns_zone_list, 1, length(local.dns_zone_list))
  parent_dns_zone_name = join(".", local.parent_dns_zone_list)
}

data "aws_route53_zone" "parent" {
  name         = local.parent_dns_zone_name
  private_zone = false
}
