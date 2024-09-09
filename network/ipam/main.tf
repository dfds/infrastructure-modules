module "ipam" {
  source       = "./_sub/network/ipam"
  ipam_name    = var.ipam_name
  ipam_regions = var.ipam_regions
  cascade      = var.cascade
  tags         = var.tags
}

output "ipam_arn" {
  value = module.ipam.arn
}

output "ipam_id" {
  value = module.ipam.id
}

module "ipam_scope_public" {
  source     = "./_sub/network/ipam-scope"
  ipam_id    = module.ipam.id
  scope_name = var.public_scope_name
  tags       = var.tags
}

module "ipam_scope_private" {
  source     = "./_sub/network/ipam-scope"
  ipam_id    = module.ipam.id
  scope_name = var.private_scope_name
  tags       = var.tags
}

module "main_pool" {
  source = "./_sub/network/ipam-pool"
  pool = {
    scope_id = module.ipam_scope_private.id
    name     = var.main_pool.name
    cidr     = var.main_pool.cidr
  }
  tags = var.tags
}

module "platform_pool" {
  source = "./_sub/network/ipam-pool"
  pool = {
    scope_id            = module.ipam_scope_private.id
    name                = var.platform_pool.name
    cidr                = var.platform_pool.cidr
    source_ipam_pool_id = module.main_pool.id
  }
  tags = var.tags
}

module "regional_platform_pools" {
  source = "./_sub/network/ipam-pool"
  count  = length(var.ipam_regions)
  pool = {
    scope_id            = module.ipam_scope_private.id
    name                = "${var.platform_pool.name}-${var.ipam_regions[count.index]}"
    cidr                = var.platform_pool.cidr // TODO: use the regional CIDRs
    region              = var.ipam_regions[count.index]
    source_ipam_pool_id = module.platform_pool.id
  }
  tags = var.tags
}

module "capabilities_pool" {
  source = "./_sub/network/ipam-pool"
  pool = {
    scope_id            = module.ipam_scope_private.id
    name                = var.capabilities_pool.name
    cidr                = var.capabilities_pool.cidr
    source_ipam_pool_id = module.main_pool.id
  }
  tags = var.tags
}

module "regional_capabilities_pools" {
  source = "./_sub/network/ipam-pool"
  count  = length(var.ipam_regions)
  pool = {
    scope_id            = module.ipam_scope_private.id
    name                = "${var.capabilities_pool.name}-${var.ipam_regions[count.index]}"
    cidr                = var.capabilities_pool.cidr // TODO: use the regional CIDRs
    source_ipam_pool_id = module.main_pool.id
  }
  tags = var.tags
}

module "unused_pool" {
  source = "./_sub/network/ipam-pool"
  pool = {
    scope_id            = module.ipam_scope_private.id
    name                = var.unused_pool.name
    cidr                = var.unused_pool.cidr
    source_ipam_pool_id = module.main_pool.id
  }
  tags = var.tags
}
