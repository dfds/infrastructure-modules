module "route53_zone" {
  source        = "../..//network/route53-zone"
  dns_zone_name = var.dns_zone_name
}

