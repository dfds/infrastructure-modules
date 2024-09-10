module "ipam" {
  source       = "../../_sub/network/ipam"
  ipam_name    = var.ipam_name
  ipam_regions = var.ipam_regions
  cascade      = var.ipam_cascade
  tags         = var.tags
}

module "ipam_scope" {
  source     = "../../_sub/network/ipam-scope"
  ipam_id    = module.ipam.id
  scope_name = var.ipam_scope_name
  tags       = var.tags
}

module "main_pool" {
  source   = "../../_sub/network/ipam-pool"
  scope_id = module.ipam_scope.id
  pool     = var.ipam_pools["main"]
  cascade  = var.ipam_pools_cascade
  tags     = var.tags
}

module "platform_pool" {
  source              = "../../_sub/network/ipam-pool"
  scope_id            = module.ipam_scope.id
  pool                = var.ipam_pools["platform"]
  source_ipam_pool_id = module.main_pool.id
  cascade             = var.ipam_pools_cascade
  tags                = var.tags
}

module "capabilities_pool" {
  source              = "../../_sub/network/ipam-pool"
  scope_id            = module.ipam_scope.id
  pool                = var.ipam_pools["capabilities"]
  source_ipam_pool_id = module.main_pool.id
  cascade             = var.ipam_pools_cascade
  tags                = var.tags
}

module "unused_pool" {
  source              = "../../_sub/network/ipam-pool"
  scope_id            = module.ipam_scope.id
  pool                = var.ipam_pools["unused"]
  source_ipam_pool_id = module.main_pool.id
  cascade             = var.ipam_pools_cascade
  tags                = var.tags
}

module "regional_platform_pools" {
  source   = "../../_sub/network/ipam-pool"
  for_each = var.ipam_pools["platform"].sub_pools
  scope_id = module.ipam_scope.id
  pool = {
    name   = "${var.ipam_pools["platform"].name}-${each.key}"
    cidr   = each.value.cidr
    region = each.key
  }
  source_ipam_pool_id = module.platform_pool.id
  tags                = var.tags
}

module "regional_capabilities_pools" {
  source   = "../../_sub/network/ipam-pool"
  for_each = var.ipam_pools["capabilities"].sub_pools
  scope_id = module.ipam_scope.id
  pool = {
    name   = "${var.ipam_pools["capabilities"].name}-${each.key}"
    cidr   = each.value.cidr
    region = each.key
  }
  source_ipam_pool_id = module.capabilities_pool.id
  tags                = var.tags
}
