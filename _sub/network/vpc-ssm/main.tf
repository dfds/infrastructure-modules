data "aws_region" "current" {}

data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "aws_security_group" "ssm" {
  name        = "ssm-eks"
  description = "SSM EKS security group"
  vpc_id      = var.vpc_id

  tags = merge(var.tags, {
    Name = "ssm-eks"
  })
}

resource "aws_vpc_security_group_ingress_rule" "ssm_https" {
  security_group_id = aws_security_group.ssm.id
  cidr_ipv4         = data.aws_vpc.vpc.cidr_block
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
  description       = "Allow SSM to VPC endpoints"

  tags = var.tags
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true

  subnet_ids = var.subnets

  security_group_ids = [
    aws_security_group.ssm.id,
  ]

  tags = merge(var.tags, {
    Name = "peering-com.amazonaws.${data.aws_region.current.name}.ssm"
  })
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true

  subnet_ids = var.subnets

  security_group_ids = [
    aws_security_group.ssm.id,
  ]

  tags = merge(var.tags, {
    Name = "peering-com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  })
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true

  subnet_ids = var.subnets

  tags = merge(var.tags, {
    Name = "peering-com.amazonaws.${data.aws_region.current.name}.ec2"
  })
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true

  subnet_ids = var.subnets

  tags = merge(var.tags, {
    Name = "peering-com.amazonaws.${data.aws_region.current.name}.ec2messages"
  })
}