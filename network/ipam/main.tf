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

module "sub_pools" {
  source   = "../../_sub/network/ipam-pool"
  for_each = { for k, v in var.ipam_pools : k => v if k != "main" }
  scope_id = module.ipam_scope.id
  pool = {
    name = length(var.ipam_prefix) > 0 ? "${var.ipam_prefix}-${each.key}" : each.key
    cidr = each.value.cidr
  }
  source_ipam_pool_id = module.main_pool.id
  cascade             = var.ipam_pools_cascade
  tags                = var.tags
}

module "regional_pools" {
  source = "../../_sub/network/ipam-pool"
  for_each = merge([
    for pool_type, pool_config in var.ipam_pools : {
      for region, region_config in pool_config.sub_pools : "${pool_type}-${region}" => {
        pool_type     = pool_type
        region        = region
        region_config = region_config
      }
    } if pool_type != "main" && can(pool_config.sub_pools)
  ]...)
  scope_id = module.ipam_scope.id
  pool = {
    name   = length(var.ipam_prefix) > 0 ? "${var.ipam_prefix}-${each.value.pool_type}-${each.value.region}" : "${each.value.pool_type}-${each.value.region}"
    cidr   = each.value.region_config.cidr
    locale = each.value.region
  }
  source_ipam_pool_id = module.sub_pools[each.value.pool_type].id
  tags                = var.tags
}

module "org-account-query" {
  source = "../../_sub/security/org-account-query"
  ou_id  = var.ipam_ou_id
}

module "ram_share" {
  source   = "../../_sub/security/resource-access-manager"
  for_each = { for k, v in var.ipam_pools : k => v if k != "main" && can(v.sub_pools) && can(v.sharing_ou_names) }

  resource_share_name = length(var.ipam_prefix) > 0 ? "ipam-${var.ipam_prefix}-${each.key}" : "ipam-${each.key}"
  resource_arns = [
    for key, pool in module.regional_pools : pool.arn if startswith(key, "${each.key}-")
  ]
  principals = [for ous in module.org-account-query.organizational_units : ous.arn if contains(each.value.sharing_ou_names, ous.name)]
  tags       = var.tags
}
