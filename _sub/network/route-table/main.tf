resource "aws_route_table" "table" {
  vpc_id = var.vpc_id

  tags = {
    Name = var.name
  }

}

resource "aws_route" "default" {
  route_table_id         = aws_route_table.table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.gateway_id
}