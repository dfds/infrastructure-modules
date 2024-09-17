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

module "org-account-query" {
  source = "../../_sub/security/org-account-query"
  ou_id  = var.ipam_ou_id
}

module "ram_share_with_platform" {
  source              = "../../_sub/security/resource-access-manager"
  resource_share_name = length(var.ipam_prefix) > 0 ? "ipam-${var.ipam_prefix}-platform" : "ipam-platform"
  resource_arns = [
    for pool in values(module.regional_platform_pools) : pool.arn
  ]
  principals = var.ipam_platform_principals
  tags       = var.tags
}

module "ram_share_with_capabilities" {
  source              = "../../_sub/security/resource-access-manager"
  resource_share_name = length(var.ipam_prefix) > 0 ? "ipam-${var.ipam_prefix}-capabilities" : "ipam-capabilities"
  resource_arns = [
    for pool in values(module.regional_capabilities_pools) : pool.arn
  ]
  principals = flatten([
    for pattern in var.ipam_role_patterns : formatlist(pattern, module.org-account-query.account_ids)
  ])
  tags = var.tags
}
