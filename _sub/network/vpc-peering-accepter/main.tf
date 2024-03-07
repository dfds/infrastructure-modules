data "aws_vpc" "peering" {
  id = var.vpc_id
}

resource "aws_route" "peer" {
  route_table_id         = data.aws_vpc.peering.main_route_table_id
  destination_cidr_block = var.destination_cidr_block
  vpc_peering_connection_id = var.peering_connection_id
}

resource "aws_vpc_peering_connection_accepter" "shared" {
  vpc_peering_connection_id = var.peering_connection_id
  auto_accept               = true

  tags = {
    Name = "peering to ${var.capability_name}"
  }
}