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

# AMI is using containerd v2 logic
data "aws_ami" "this" {
  filter {
    name   = "image-id"
    values = [local.node_ami]
  }
  most_recent = true
  owners      = ["602401143452"] # Amazon Account ID
}

locals {
  ami_defined_cluster_version = reverse(split("-", data.aws_ami.this.name))[1]                                                                                                                                                           # cluster version from AMI name, e.g. "amazon-eks-node-al2023-x86_64-standard-1.33-v20251016" -> 1.33
  cluster_version_gt_133      = (tonumber(split(".", local.ami_defined_cluster_version)[0]) == 1 && tonumber(split(".", local.ami_defined_cluster_version)[1]) >= 34) || tonumber(split(".", local.ami_defined_cluster_version)[0]) >= 2 # versions above 1.33 uses containerd v2, which uses different syntaxt for image registry auth

  ami_date = tonumber(trim(reverse(split("-", data.aws_ami.this.name))[0], "v")) # extracts the date from the AMI name, e.g. "amazon-eks-node-al2023-x86_64-standard-1.33-v20251016" -> 20251016

  cluster_version_containerdv2_cuttoff_date = {
    "1.33" = 20251016
    "1.32" = 20251023
    "1.31" = 20251030
    "1.30" = 20251106
  } # dates containerd v2 will be backported to EKS Optimized AL2023 AMIs (https://github.com/awslabs/amazon-eks-ami/issues/2470#issue-3514989135)

  ami_using_containerd_v2 = local.cluster_version_gt_133 || local.ami_date >= lookup(local.cluster_version_containerdv2_cuttoff_date, local.ami_defined_cluster_version, 99999999) # first portion checks if cluster version is > 1.33, second portion checks if AMI date is >= cuttoff date for the cluster version
}
