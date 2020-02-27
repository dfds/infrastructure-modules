resource "aws_subnet" "subnet" {
  count             = length(var.cidr_blocks)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.cidr_blocks[count.index]
  vpc_id            = var.vpc_id

  tags = {
    "Name" = var.name
  }
}

