# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_availability_zones" "available" {
}

resource "aws_vpc" "eks" {
  cidr_block = var.cidr_block

  tags = {
    "Name"                                      = "eks-${var.cluster_name}-cluster"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Disable ingress/egress in the default security group in the VPC
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.eks.id
}

module "flow_log" {
  source   = "../../../_sub/network/vpc-flow-log"
  log_name = "eks-${var.cluster_name}-cluster"
  vpc_id   = aws_vpc.eks.id
}

locals {
  prefix             = substr(var.cluster_reserved_cidr, -3, -1)               # Find the last octet of the reserved CIDR block
  subnets_pool       = replace(var.cluster_reserved_cidr, local.prefix, "/22") # Replace the last octet with /22 to create a subnet pool
  calculated_subnets = cidrsubnets(local.subnets_pool, 2, 2, 2)
}

resource "aws_subnet" "eks" {
  count = length(local.calculated_subnets)

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = local.calculated_subnets[count.index]
  vpc_id            = aws_vpc.eks.id

  tags = {
    "Name"                                      = "eks-${var.cluster_name}-control-plane-${data.aws_availability_zones.available.names[count.index]}"
    "Description"                               = "Subnet reserved for the EKS control plane of the ${var.cluster_name} cluster."
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}
