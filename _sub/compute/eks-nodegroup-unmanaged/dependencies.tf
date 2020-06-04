data "aws_ami" "eks-node" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-${var.cluster_version}-*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon Account ID
}

data "aws_ami" "eks-gpu-node" {
  filter {
    name   = "name"
    values = ["amazon-eks-gpu-node-${var.cluster_version}-*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon Account ID
}

locals {
  # Use GPU AMI if 'gpu_ami' is true
  node_ami = var.gpu_ami ? data.aws_ami.eks-gpu-node.id : data.aws_ami.eks-node.id
}

data "aws_subnet" "subnet" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}
