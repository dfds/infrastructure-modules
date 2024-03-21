data "aws_region" "current" {}

resource "aws_vpc" "peering" {

  cidr_block = var.cidr_block_vpc
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "peering"
  })

  tags_all = merge(var.tags, {
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

### SSM Support

resource "aws_security_group" "ssm" {
  name = "ssm-tunnel"
  description = "Attach this security group to items that need to communicate with SSM for tunneling"
  vpc_id = aws_vpc.peering.id

  tags = var.tags
}

resource "aws_vpc_security_group_egress_rule" "ssm_postgres" {
  security_group_id = aws_security_group.ssm.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 5432
  to_port           = 5432
  description = "Allow SSM to Postgres"

  tags = var.tags
}

resource "aws_vpc_security_group_egress_rule" "ssm_https" {
  security_group_id = aws_security_group.ssm.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description = "Allow SSM to VPC endpoints"

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "sec_sec" {
  security_group_id = aws_vpc.peering.default_security_group_id
  referenced_security_group_id = aws_security_group.ssm.id
  description = "Postgres access from Hellman Kubernetes cluster"

  ip_protocol = -1


  tags = var.tags
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id = aws_vpc.peering.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true

  subnet_ids = flatten([aws_subnet.a.id, aws_subnet.b.id, var.cidr_block_subnet_c != "" ? aws_subnet.c[0].id : []])

  security_group_ids = [
    aws_security_group.ssm.id,
    aws_vpc.peering.default_security_group_id
  ]

  tags = var.tags
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id = aws_vpc.peering.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true

  subnet_ids = flatten([aws_subnet.a.id, aws_subnet.b.id, var.cidr_block_subnet_c != "" ? aws_subnet.c[0].id : []])

  security_group_ids = [
    aws_security_group.ssm.id,
    aws_vpc.peering.default_security_group_id
  ]

  tags = var.tags
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id = aws_vpc.peering.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.ec2"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true

  subnet_ids = flatten([aws_subnet.a.id, aws_subnet.b.id, var.cidr_block_subnet_c != "" ? aws_subnet.c[0].id : []])

  security_group_ids = [
    aws_security_group.ssm.id,
    aws_vpc.peering.default_security_group_id
  ]

  tags = var.tags
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id = aws_vpc.peering.id
  service_name = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true

  subnet_ids = flatten([aws_subnet.a.id, aws_subnet.b.id, var.cidr_block_subnet_c != "" ? aws_subnet.c[0].id : []])

  security_group_ids = [
    aws_security_group.ssm.id,
    aws_vpc.peering.default_security_group_id
  ]

  tags = var.tags
}

data "aws_iam_policy_document" "ssm_trust" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }

}

resource "aws_iam_role" "ssm_tunnel" {
  name = "ssm-tunnel"
  assume_role_policy = data.aws_iam_policy_document.ssm_trust.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]


  tags = var.tags
}

resource "aws_iam_instance_profile" "ssm_tunnel" {
  name = aws_iam_role.ssm_tunnel.name
  role = aws_iam_role.ssm_tunnel.name
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
