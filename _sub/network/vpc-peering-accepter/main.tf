resource "aws_route" "peer" {
  route_table_id         = aws_vpc.peering.main_route_table_id
  destination_cidr_block = var.capability_ip_range
  vpc_peering_connection_id = aws_vpc_peering_connection.capability.id
}

resource "aws_vpc_peering_connection_accepter" "shared" {
  vpc_peering_connection_id = aws_vpc_peering_connection.capability.id
  auto_accept               = true

  tags = {
    Name = "peering to ${var.capability_name}"
  }
}