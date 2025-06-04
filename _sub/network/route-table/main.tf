locals {
  tags = merge(var.tags, {
    Name = var.name
  })
}

resource "aws_route_table" "table" {
  vpc_id = var.vpc_id

  tags = local.tags

}

resource "aws_route" "default" {
  route_table_id         = aws_route_table.table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.gateway_id
  nat_gateway_id         = var.nat_gateway_id
}

data "aws_vpc_peering_connections" "pcs" {
  filter {
    name   = "accepter-vpc-info.vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_vpc_peering_connection" "pc" {
  count = var.migrate_vpc_peering_routes ? length(data.aws_vpc_peering_connections.pcs.ids) : 0
  id    = data.aws_vpc_peering_connections.pcs.ids[count.index]
}

resource "aws_route" "peering" {
  count                     = var.migrate_vpc_peering_routes ? length(data.aws_vpc_peering_connections.pcs.ids) : 0
  route_table_id            = aws_route_table.table.id
  destination_cidr_block    = data.aws_vpc_peering_connection.pc[count.index].cidr_block
  vpc_peering_connection_id = data.aws_vpc_peering_connection.pc[count.index].id
}
