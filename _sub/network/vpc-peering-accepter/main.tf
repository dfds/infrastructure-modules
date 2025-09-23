data "aws_region" "current" {}

data "aws_route_tables" "preferred" {
  vpc_id = var.vpc_id
  tags = {
    "vpc.peering.actor" = "accepter"
  }
}

data "aws_route_tables" "alternate" {
  vpc_id = var.vpc_id
  filter {
    name   = "association.main"
    values = ["false"]
  }
  filter {
    name   = "route.gateway-id"
    values = ["local"]
  }
  filter {
    name   = "tag:Name"
    values = ["eks-*-sub*"]
  }
}

locals {
  len     = length(data.aws_route_tables.preferred.ids)
  alt_len = length(data.aws_route_tables.alternate.ids)
}

# If the preferred route table has routes, use it. Otherwise, use the alternate route table.
# If neither have routes, create a route in the main route table based on the var.route_table_id
resource "aws_route" "peer" {
  count = local.len > 0 ? local.len : local.alt_len > 0 ? local.alt_len : 1
  route_table_id = try(
    try(
      data.aws_route_tables.preferred.ids[count.index],
      data.aws_route_tables.alternate.ids[count.index]
    ), var.route_table_id
  )
  destination_cidr_block    = var.destination_cidr_block
  vpc_peering_connection_id = var.peering_connection_id
}

resource "aws_vpc_peering_connection_accepter" "shared" {
  vpc_peering_connection_id = var.peering_connection_id
  auto_accept               = true

  tags = merge(var.tags, {
    Name = "${var.capability_id}_${data.aws_region.current.region}"
  })
}
