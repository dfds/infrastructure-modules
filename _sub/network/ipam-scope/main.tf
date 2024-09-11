locals {
  all_tags = merge(var.tags, { "Name" = var.scope_name })
}

// Create an addional IPAM private scope
resource "aws_vpc_ipam_scope" "this" {
  ipam_id     = var.ipam_id
  description = var.scope_name
  tags        = local.all_tags
}
