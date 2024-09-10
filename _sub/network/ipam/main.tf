data "aws_region" "current" {}

locals {
  all_ipam_regions = distinct(concat([data.aws_region.current.name], var.ipam_regions))
  all_tags         = merge(var.tags, { "Name" = var.ipam_name })
}

resource "aws_vpc_ipam" "this" {
  description = "${var.ipam_name} AWS IPAM"
  dynamic "operating_regions" {
    for_each = local.all_ipam_regions
    content {
      region_name = operating_regions.value
    }
  }
  tier    = var.ipam_tier
  cascade = var.cascade
  tags    = local.all_tags
}
