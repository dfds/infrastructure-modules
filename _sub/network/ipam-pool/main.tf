locals {
  name_tag = {
    Name = var.pool.name
  }
  all_tags = merge(var.tags, local.name_tag)
}

resource "aws_vpc_ipam_pool" "this" {
  ipam_scope_id       = var.pool.scope_id
  address_family      = var.pool.address_family
  locale              = var.pool.locale
  auto_import         = var.pool.locale ? true : false
  source_ipam_pool_id = var.pool.source_ipam_pool_id ? var.pool.source_ipam_pool_id : null
  tags                = local.all_tags
}

resource "aws_vpc_ipam_pool_cidr" "this" {
  ipam_pool_id = aws_vpc_ipam_pool.this.id
  cidr         = var.pool.cidr
}
