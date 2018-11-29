# This data source is included for ease of sample architecture deployment
# and can be swapped out as necessary.
data "aws_availability_zones" "available" {}

resource "aws_vpc" "eks" {
  cidr_block = "10.0.0.0/16"

  tags = "${
    map(
     "Name", "eks-${var.cluster_name}-node",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}

resource "aws_subnet" "eks" {
  count = 2

  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = "${aws_vpc.eks.id}"

  tags = "${
    map(
     "Name", "eks-${var.cluster_name}-node",
     "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}

resource "aws_internet_gateway" "eks" {
  vpc_id = "${aws_vpc.eks.id}"

  tags {
    Name = "eks-${var.cluster_name}"
  }
}

resource "aws_route_table" "eks" {
  vpc_id = "${aws_vpc.eks.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.eks.id}"
  }
}

resource "aws_route_table_association" "eks" {
  count = 2

  subnet_id      = "${aws_subnet.eks.*.id[count.index]}"
  route_table_id = "${aws_route_table.eks.id}"
}