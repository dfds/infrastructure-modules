data "aws_region" "current" {}

resource "aws_vpc" "peering" {

  cidr_block = var.cidr_block_vpc

  tags = merge(var.tags, {
    Name = "peering"
  })
}

resource "aws_subnet" "a" {

  vpc_id = aws_vpc.peering.id

  cidr_block = var.cidr_block_subnet_a
  availability_zone = "${data.aws_region.current.name}a"

  tags = merge(var.tags,{
    Name = "peering-a"
  })

}

resource "aws_subnet" "b" {
  vpc_id = aws_vpc.peering.id

  cidr_block = var.cidr_block_subnet_b
  availability_zone = "${data.aws_region.current.name}b"

  tags = merge(var.tags,{
    Name = "peering-b"
  })
}

resource "aws_subnet" "c" {

  # This is a legacy/optional subnet, so we only create it if the cidr_block_subnet_c variable is set

  count  = var.cidr_block_subnet_c != "" ? 1 : 0
  vpc_id = aws_vpc.peering.id

  cidr_block = var.cidr_block_subnet_c

  tags = merge(var.tags,{
    Name = "peering-c"
  })
}

resource "aws_vpc_security_group_ingress_rule" "postgres" {
  security_group_id = aws_vpc.peering.default_security_group_id
  cidr_ipv4         = var.cidr_block_peer
  ip_protocol       = "tcp"
  from_port         = 5432
  to_port           = 5432
  description = "Postgres access from Hellman Kubernetes cluster"

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "redis" {
  security_group_id = aws_vpc.peering.default_security_group_id
  cidr_ipv4         = var.cidr_block_peer
  ip_protocol       = "tcp"
  from_port         = 6379
  to_port           = 6379
  description = "Redis access from Hellman Kubernetes cluster"

  tags = var.tags
}

# TODO: Our instructions prepare an RDS subnet group. 
# Not technically a VPC feature but let's do that here
# or make a decision to miss it out
resource "aws_db_subnet_group" "peering" {
  name       = "peering"
  subnet_ids = flatten([aws_subnet.a.id, aws_subnet.b.id, var.cidr_block_subnet_c != "" ? aws_subnet.c[0].id : []])

  tags = {
    Name = "peering"
  }
}


resource "aws_vpc_peering_connection" "capability" {
  peer_owner_id = var.peer_owner_id
  peer_vpc_id   = var.peer_vpc_id
  peer_region   = var.peer_region
  vpc_id        = aws_vpc.peering.id

  tags = merge(var.tags,{
    Name = "peering to hellman"
  })
}

resource "aws_route" "capability_to_shared" {
  route_table_id            = aws_vpc.peering.main_route_table_id
  destination_cidr_block    = var.cidr_block_peer
  vpc_peering_connection_id = aws_vpc_peering_connection.capability.id
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.peering.id

  tags = merge(var.tags,{
    Name = "peering-igw"
  })
}

resource "aws_route" "default" {
  route_table_id         = aws_vpc.peering.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}
