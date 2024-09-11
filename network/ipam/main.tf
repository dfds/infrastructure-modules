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
  scope_name = length(var.ipam_prefix) > 0 ? "${var.ipam_prefix}-${var.ipam_scope_name}" : var.ipam_scope_name
  tags       = var.tags
}

module "main_pool" {
  source   = "../../_sub/network/ipam-pool"
  scope_id = module.ipam_scope.id
  pool = {
    name = length(var.ipam_prefix) > 0 ? "${var.ipam_prefix}-main" : "main"
    cidr = var.ipam_pools["main"].cidr
  }
  cascade = var.ipam_pools_cascade
  tags    = var.tags
}

module "platform_pool" {
  source   = "../../_sub/network/ipam-pool"
  scope_id = module.ipam_scope.id
  pool = {
    name = length(var.ipam_prefix) > 0 ? "${var.ipam_prefix}-platform" : "platform"
    cidr = var.ipam_pools["platform"].cidr
  }
  source_ipam_pool_id = module.main_pool.id
  cascade             = var.ipam_pools_cascade
  tags                = var.tags
}

module "capabilities_pool" {
  source   = "../../_sub/network/ipam-pool"
  scope_id = module.ipam_scope.id
  pool = {
    name = length(var.ipam_prefix) > 0 ? "${var.ipam_prefix}-capabilities" : "capabilities"
    cidr = var.ipam_pools["capabilities"].cidr
  }
  source_ipam_pool_id = module.main_pool.id
  cascade             = var.ipam_pools_cascade
  tags                = var.tags
}

module "unused_pool" {
  source   = "../../_sub/network/ipam-pool"
  scope_id = module.ipam_scope.id
  pool = {
    name = length(var.ipam_prefix) > 0 ? "${var.ipam_prefix}-unused" : "unused"
    cidr = var.ipam_pools["unused"].cidr
  }
  source_ipam_pool_id = module.main_pool.id
  cascade             = var.ipam_pools_cascade
  tags                = var.tags
}

module "regional_platform_pools" {
  source   = "../../_sub/network/ipam-pool"
  for_each = var.ipam_pools["platform"].sub_pools
  scope_id = module.ipam_scope.id
  pool = {
    name   = length(var.ipam_prefix) > 0 ? "${var.ipam_prefix}-platform-${each.key}" : "platform-${each.key}"
    cidr   = each.value.cidr
    locale = each.key
  }
  source_ipam_pool_id = module.platform_pool.id
  tags                = var.tags
}

module "regional_capabilities_pools" {
  source   = "../../_sub/network/ipam-pool"
  for_each = var.ipam_pools["capabilities"].sub_pools
  scope_id = module.ipam_scope.id
  pool = {
    name   = length(var.ipam_prefix) > 0 ? "${var.ipam_prefix}-capabilities-${each.key}" : "capabilities-${each.key}"
    cidr   = each.value.cidr
    locale = each.key
  }
  source_ipam_pool_id = module.capabilities_pool.id
  tags                = var.tags
}
