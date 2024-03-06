resource "aws_vpc" "peering" {

  cidr_block = var.cidr_block_vpc

  tags = {
    Name = "peering"
  }
}

resource "aws_subnet" "a" {

  vpc_id = aws_vpc.peering.id

  cidr_block = var.cidr_block_subnet_a

  tags = {
    Name = "peering-a"
  }

}

resource "aws_subnet" "b" {
  vpc_id = aws_vpc.peering.id

  cidr_block = var.cidr_block_subnet_b

  tags = {
    Name = "peering-b"
  }
}

resource "aws_subnet" "c" {

  # This is a legacy/optional subnet, so we only create it if the cidr_block_subnet_c variable is set

  count  = var.cidr_block_subnet_c != "" ? 1 : 0
  vpc_id = aws_vpc.peering.id

  cidr_block = var.cidr_block_subnet_c

  tags = {
    Name = "peering-c"
  }
}

# TODO: Our instructions prepare a security group for postgres.
# We might want to use a map here with default values that lets us 
# append to the values if required

resource "aws_vpc_security_group_ingress_rule" "postgres" {
  security_group_id = aws_vpc.peering.default_security_group_id
  cidr_ipv4         = var.cidr_block_peer
  ip_protocol       = "tcp"
  to_port           = 5432
}

# TODO: Our instructions prepare an RDS subnet group. 
# Not technically a VPC feature but let's do that here
# TBC


resource "aws_vpc_peering_connection" "capability" {
  peer_owner_id = var.peer_owner_id
  peer_vpc_id   = var.peer_vpc_id
  peer_region   = var.peer_region
  vpc_id        = aws_vpc.peering.id

  tags = {
    Name = "peering to hellman"
  }
}

resource "aws_route" "capability_to_shared" {
  route_table_id            = aws_vpc.peering.main_route_table_id
  destination_cidr_block    = var.cidr_block_peer
  vpc_peering_connection_id = aws_vpc_peering_connection.capability.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.peering.id

  tags = {
    Name = "peering-igw"
  }
}

resource "aws_route" "capability_to_shared" {
  route_table_id            = aws_vpc.peering.main_route_table_id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}