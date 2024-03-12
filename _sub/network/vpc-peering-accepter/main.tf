data "aws_vpc" "peering" {
  id = var.vpc_id
}

data "aws_region" "current" {}

resource "aws_route" "peer" {
  route_table_id         = var.route_table_id
  destination_cidr_block = var.destination_cidr_block
  vpc_peering_connection_id = var.peering_connection_id
}

resource "aws_vpc_peering_connection_accepter" "shared" {
  vpc_peering_connection_id = var.peering_connection_id
  auto_accept               = true

  tags = {
    Name = "${var.capability_id}_${data.aws_region.current.name}"
  }
}