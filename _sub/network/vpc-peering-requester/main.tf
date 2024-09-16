data "aws_region" "current" {}

# TODO: IPAM will only work if we trust the role used by our pipeline
data "aws_vpc_ipam_pool" "this" {
  count        = var.ipam_cidr_enable && var.ipam_pool != "" ? 1 : 0
  ipam_pool_id = var.ipam_pool
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc_ipam_preview_next_cidr" "this" {
  count          = var.ipam_cidr_enable && var.ipam_pool != "" ? 1 : 0
  ipam_pool_id   = data.aws_vpc_ipam_pool.this[0].id
  netmask_length = var.ipam_cidr_prefix
}

locals {
  subnets            = var.ipam_cidr_enable ? cidrsubnets(aws_vpc_ipam_preview_next_cidr.this[0].cidr, var.ipam_subnet_bits...) : []
  availability_zones = slice(data.aws_availability_zones.available.names, 0, length(var.ipam_subnet_bits))
}

resource "aws_vpc" "peering" {
  ipv4_ipam_pool_id    = var.ipam_cidr_enable && var.ipam_pool != "" ? data.aws_vpc_ipam_pool.this[0].id : null
  ipv4_netmask_length  = var.ipam_cidr_enable && var.ipam_cidr_prefix != "" ? var.ipam_cidr_prefix : null
  cidr_block           = var.ipam_cidr_enable ? null : var.cidr_block_vpc
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name = "peering-${var.configuration_name}"
  })
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.peering.id

  tags = merge(var.tags, {
    Name = "peering-${var.configuration_name}"
  })
}

resource "aws_vpc_security_group_egress_rule" "default" {
  security_group_id = aws_default_security_group.default.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "default" {
  security_group_id            = aws_default_security_group.default.id
  referenced_security_group_id = aws_default_security_group.default.id
  ip_protocol                  = -1

  tags = var.tags
}

resource "aws_subnet" "this" {
  count                   = var.ipam_cidr_enable ? length(var.ipam_subnet_bits) : 0
  vpc_id                  = aws_vpc.peering.id
  map_public_ip_on_launch = var.map_public_ip_on_launch
  cidr_block              = element(local.subnets, count.index)
  availability_zone       = element(local.availability_zones, count.index)

  tags = merge(var.tags, {
    Name = "peering-${element(local.availability_zones, count.index)}"
  })
}

resource "aws_subnet" "a" {
  count                   = var.ipam_cidr_enable ? 0 : 1
  vpc_id                  = aws_vpc.peering.id
  map_public_ip_on_launch = var.map_public_ip_on_launch
  cidr_block              = var.cidr_block_subnet_a
  availability_zone       = "${data.aws_region.current.name}a"

  tags = merge(var.tags, {
    Name = "peering-a"
  })

}

resource "aws_subnet" "b" {
  count                   = var.ipam_cidr_enable ? 0 : 1
  vpc_id                  = aws_vpc.peering.id
  map_public_ip_on_launch = var.map_public_ip_on_launch
  cidr_block              = var.cidr_block_subnet_b
  availability_zone       = "${data.aws_region.current.name}b"

  tags = merge(var.tags, {
    Name = "peering-b"
  })
}

resource "aws_subnet" "c" {

  # This is a legacy/optional subnet, so we only create it if the cidr_block_subnet_c variable is set
  count                   = var.ipam_cidr_enable ? 0 : var.cidr_block_subnet_c != "" ? 1 : 0
  vpc_id                  = aws_vpc.peering.id
  map_public_ip_on_launch = var.map_public_ip_on_launch
  cidr_block              = var.cidr_block_subnet_c

  tags = merge(var.tags, {
    Name = "peering-c"
  })
}

### SSM Support

resource "aws_security_group" "ssm" {
  name        = "ssm-tunnel"
  description = "Attach this security group to items that need to communicate with SSM for tunneling"
  vpc_id      = aws_vpc.peering.id

  tags = merge(var.tags, {
    Name = "ssm-tunnel"
  })
}

resource "aws_vpc_security_group_egress_rule" "ssm_postgres" {
  security_group_id = aws_security_group.ssm.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 5432
  to_port           = 5432
  description       = "Allow SSM to Postgres"

  tags = var.tags
}

resource "aws_vpc_security_group_egress_rule" "ssm_https" {
  security_group_id = aws_security_group.ssm.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "Allow SSM to VPC endpoints"

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "sec_sec" {
  security_group_id            = aws_default_security_group.default.id
  referenced_security_group_id = aws_security_group.ssm.id
  description                  = "Postgres access from Hellman Kubernetes cluster"

  ip_protocol = -1


  tags = var.tags
}

resource "aws_vpc_endpoint" "ssm" {
  count             = var.deploy_vpc_peering_endpoints ? 1 : 0
  vpc_id            = aws_vpc.peering.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true

  subnet_ids = var.ipam_cidr_enable ? [for subnet in aws_subnet.this : subnet.id] : flatten(
    [
      var.cidr_block_subnet_a != "" ? aws_subnet.a[0].id : "",
      var.cidr_block_subnet_b != "" ? aws_subnet.b[0].id : "",
      var.cidr_block_subnet_c != "" ? aws_subnet.c[0].id : ""
    ]
  )

  security_group_ids = [
    aws_security_group.ssm.id,
    aws_default_security_group.default.id
  ]

  tags = merge(var.tags, {
    Name = "peering-com.amazonaws.${data.aws_region.current.name}.ssm"
  })
}

resource "aws_vpc_endpoint" "ssmmessages" {
  count             = var.deploy_vpc_peering_endpoints ? 1 : 0
  vpc_id            = aws_vpc.peering.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true

  subnet_ids = var.ipam_cidr_enable ? [for subnet in aws_subnet.this : subnet.id] : flatten(
    [
      var.cidr_block_subnet_a != "" ? aws_subnet.a[0].id : "",
      var.cidr_block_subnet_b != "" ? aws_subnet.b[0].id : "",
      var.cidr_block_subnet_c != "" ? aws_subnet.c[0].id : ""
    ]
  )

  security_group_ids = [
    aws_security_group.ssm.id,
    aws_default_security_group.default.id
  ]

  tags = merge(var.tags, {
    Name = "peering-com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  })
}

resource "aws_vpc_endpoint" "ec2" {
  count             = var.deploy_vpc_peering_endpoints ? 1 : 0
  vpc_id            = aws_vpc.peering.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true

  subnet_ids = var.ipam_cidr_enable ? [for subnet in aws_subnet.this : subnet.id] : flatten(
    [
      var.cidr_block_subnet_a != "" ? aws_subnet.a[0].id : "",
      var.cidr_block_subnet_b != "" ? aws_subnet.b[0].id : "",
      var.cidr_block_subnet_c != "" ? aws_subnet.c[0].id : ""
    ]
  )

  security_group_ids = [
    aws_security_group.ssm.id,
    aws_default_security_group.default.id
  ]

  tags = merge(var.tags, {
    Name = "peering-com.amazonaws.${data.aws_region.current.name}.ec2"
  })
}

resource "aws_vpc_endpoint" "ec2messages" {
  count             = var.deploy_vpc_peering_endpoints ? 1 : 0
  vpc_id            = aws_vpc.peering.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true

  subnet_ids = var.ipam_cidr_enable ? [for subnet in aws_subnet.this : subnet.id] : flatten(
    [
      var.cidr_block_subnet_a != "" ? aws_subnet.a[0].id : "",
      var.cidr_block_subnet_b != "" ? aws_subnet.b[0].id : "",
      var.cidr_block_subnet_c != "" ? aws_subnet.c[0].id : ""
    ]
  )

  security_group_ids = [
    aws_security_group.ssm.id,
    aws_default_security_group.default.id
  ]

  tags = merge(var.tags, {
    Name = "peering-com.amazonaws.${data.aws_region.current.name}.ec2messages"
  })
}

data "aws_iam_policy_document" "ssm_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }

}

resource "aws_iam_role" "ssm_tunnel" {
  name                = "ssm-tunnel-${var.configuration_name}"
  assume_role_policy  = data.aws_iam_policy_document.ssm_trust.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]


  tags = var.tags
}

resource "aws_iam_instance_profile" "ssm_tunnel" {
  name = aws_iam_role.ssm_tunnel.name
  role = aws_iam_role.ssm_tunnel.name
}

resource "aws_vpc_security_group_ingress_rule" "postgres" {
  security_group_id = aws_default_security_group.default.id
  cidr_ipv4         = var.cidr_block_peer
  ip_protocol       = "tcp"
  from_port         = 5432
  to_port           = 5432
  description       = "Postgres access from Hellman Kubernetes cluster"

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "redis" {
  security_group_id = aws_default_security_group.default.id
  cidr_ipv4         = var.cidr_block_peer
  ip_protocol       = "tcp"
  from_port         = 6379
  to_port           = 6379
  description       = "Redis access from Hellman Kubernetes cluster"

  tags = var.tags
}

resource "aws_db_subnet_group" "peering" {
  name = "peering-${var.configuration_name}"
  subnet_ids = var.ipam_cidr_enable ? [for subnet in aws_subnet.this : subnet.id] : flatten(
    [
      var.cidr_block_subnet_a != "" ? aws_subnet.a[0].id : "",
      var.cidr_block_subnet_b != "" ? aws_subnet.b[0].id : "",
      var.cidr_block_subnet_c != "" ? aws_subnet.c[0].id : ""
    ]
  )

  tags = {
    Name = "peering-${var.configuration_name}"
  }
}


resource "aws_vpc_peering_connection" "capability" {
  peer_owner_id = var.peer_owner_id
  peer_vpc_id   = var.peer_vpc_id
  peer_region   = var.peer_region
  vpc_id        = aws_vpc.peering.id

  tags = merge(var.tags, {
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

  tags = merge(var.tags, {
    Name = "peering-${var.configuration_name}"
  })
}

resource "aws_route" "default" {
  route_table_id         = aws_vpc.peering.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}
