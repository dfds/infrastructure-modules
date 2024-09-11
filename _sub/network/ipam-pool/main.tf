locals {
  all_tags = merge(var.tags, { "Name" = var.pool.name })
}

resource "aws_vpc_ipam_pool" "this" {
  ipam_scope_id       = var.scope_id
  address_family      = var.pool.address_family
  locale              = var.pool.locale
  auto_import         = var.pool.locale != null ? true : false
  source_ipam_pool_id = var.source_ipam_pool_id != null ? var.source_ipam_pool_id : null
  description         = var.pool.name
  cascade             = var.cascade
  tags                = local.all_tags
}

resource "aws_vpc_ipam_pool_cidr" "this" {
  ipam_pool_id = aws_vpc_ipam_pool.this.id
  cidr         = var.pool.cidr
}
