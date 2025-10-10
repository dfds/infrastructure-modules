locals {
  asg_desired_size = length(var.subnet_ids) * var.desired_size_per_subnet
  # A sandbox should be able to be put scaled down to 0 at the end of the workday.
  asg_min_size = var.enable_scale_to_zero_after_business_hours ? 0 : local.asg_desired_size
  asg_max_size = 2 * local.asg_desired_size
}

data "aws_ami" "eks-node" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-al2023-x86_64-standard-${var.cluster_version}-*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon Account ID
}


data "aws_ami" "eks-gpu-node" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-al2023-x86_64-nvidia-${var.cluster_version}-*"]
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

locals {
  ami_using_containerd_v2 = (tonumber(split(".", var.cluster_version)[0]) == 1 && tonumber(split(".", var.cluster_version)[1]) >= 34) || tonumber(split(".", var.cluster_version)[0]) >= 2 # versions above 1.33 uses containerd v2, which uses different syntaxt for image registry auth
}
