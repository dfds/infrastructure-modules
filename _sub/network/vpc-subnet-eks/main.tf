resource "aws_subnet" "subnet" {
  count             = var.deploy ? length(var.subnets) : 0
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = var.subnets[count.index]
  vpc_id            = var.vpc_id

  tags = {
    "Name"                                      = "${var.name}-nodes-${data.aws_availability_zones.available.names[count.index]}"
    "Description"                               = "Subnet for worker nodes and Kubernetes resource in the ${var.cluster_name} cluster."
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

