locals {
  all_tags = merge(var.tags, var.scope_name)
}

resource "aws_vpc_ipam_scope" "this" {
  ipam_id     = var.ipam_id
  description = var.scope_name
  tags        = local.all_tags
}
