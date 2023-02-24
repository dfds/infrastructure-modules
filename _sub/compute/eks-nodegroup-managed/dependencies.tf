locals {
  asg_desired_size = length(var.subnet_ids) * var.desired_size_per_subnet
  asg_min_size     = var.is_sandbox ? 0 : local.asg_desired_size
  asg_max_size     = 2 * local.asg_desired_size
}

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
  # Determine the latest AMI for the specified cluster version using the GPU variant if the 'gpu_ami' is set to true.
  latest_ami = var.gpu_ami ? data.aws_ami.eks-gpu-node.id : data.aws_ami.eks-node.id
}

locals {
  # Pins AMI to 'ami_id' if it is set, otherwise, sets to the latest AMI.
  node_ami = var.ami_id != "" ? var.ami_id : local.latest_ami
}

data "aws_subnet" "subnet" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}

locals {
  /*
  https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/#example-use-cases
  https://aws.amazon.com/blogs/opensource/improvements-eks-worker-node-provisioning/
  */
  bootstrap_extra_args = length(var.kubelet_extra_args) >= 1 ? "--kubelet-extra-args '${var.kubelet_extra_args}'" : ""
}
