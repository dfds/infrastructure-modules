resource "aws_subnet" "subnet" {
  count             = var.deploy ? length(var.subnets) : 0
  availability_zone = var.subnets[count.index].availability_zone
  cidr_block        = var.subnets[count.index].subnet_cidr
  vpc_id            = var.vpc_id

  tags = {
    "Name"                                      = "${var.name}-${data.aws_availability_zones.available.names[count.index]}"
    "Description"                               = "Subnet for worker nodes and Kubernetes resource in the ${var.cluster_name} cluster."
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_ec2_subnet_cidr_reservation" "prefix_reservation" {
  for_each = {
    for res in flatten([
      for index, subnet in aws_subnet.subnet : [
        for cidr in var.subnets[index].prefix_reservations_cidrs : {
          subnet_id  = subnet.id,
          cidr_block = cidr
        }
      ]
  ]) : "${res.cidr_block}" => res }
  reservation_type = "prefix"
  cidr_block       = each.value.cidr_block
  subnet_id        = each.value.subnet_id
}
