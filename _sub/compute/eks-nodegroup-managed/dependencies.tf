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

locals {
  # Pins AMI to 'ami_id' if it is set, otherwise, sets to the latest AMI.
  node_ami = var.ami_id != "" ? var.ami_id : data.aws_ami.eks-node.id
}

locals {
  max_pods = 110
}

data "aws_ec2_instance_type" "this" {
  for_each = toset(var.instance_types)
  instance_type = each.value
}

locals {
  max_pods_calc = {
    for instance_type, instance_data in data.aws_ec2_instance_type.this : instance_type => (
      (instance_data.maximum_network_interfaces * ((instance_data.maximum_ipv4_addresses_per_interface - 1) * 16)) + 2
    )
  }
}

check "instance_types_support_max_pods" {
 assert {
    condition     = alltrue([for instance_type, instance_data in local.max_pods_calc : (
      instance_data >= local.max_pods
    )])
    error_message = "One or more instance types is too small and does not support the required max pods of ${local.max_pods}."
  }
}
