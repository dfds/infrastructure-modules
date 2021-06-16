resource "aws_launch_configuration" "eks" {
  count                       = signum(var.desired_size_per_subnet)
  associate_public_ip_address = true
  iam_instance_profile        = var.iam_instance_profile
  image_id                    = local.node_ami
  instance_type               = element(var.instance_types, 0)
  name_prefix                 = "eks-${var.cluster_name}-${var.nodegroup_name}-"
  security_groups             = var.security_groups
  user_data_base64            = var.cloudwatch_agent_enabled ? base64encode(local.worker-node-userdata-cw-agent) : base64encode(local.worker-node-userdata)
  key_name                    = var.ec2_ssh_key

  root_block_device {
    volume_size = var.disk_size
    volume_type = "gp2"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html
resource "aws_placement_group" "cluster" {
  name     = "eks_${var.cluster_name}_${var.nodegroup_name}"
  strategy = "cluster"
}


locals {
  asg_min_size = 0 # Allow scaling an ASG to zero, e.g. for maintenance og dialing down sandbox clusters at night
  asg_max_size = 2 * var.desired_size_per_subnet # Allows node roll-over script to double the instance count, to roll-over all nodes in an ASG in one operation
}


resource "aws_autoscaling_group" "eks" {
  count                = var.desired_size_per_subnet > 0 ? length(var.subnet_ids) : 0
  name                 = "eks-${var.cluster_name}-${var.nodegroup_name}_${data.aws_subnet.subnet[count.index].availability_zone}"
  launch_configuration = try(aws_launch_configuration.eks[0].id, ["NA"])
  min_size             = local.asg_min_size
  max_size             = local.asg_max_size
  desired_capacity     = var.desired_size_per_subnet
  vpc_zone_identifier  = toset([data.aws_subnet.subnet[count.index].id])

  # The following can be set in case of the default health check are not sufficient
  #health_check_grace_period = 5
  #default_cooldown = 15

  tag {
    key                 = "Name"
    value               = "eks-${var.cluster_name}-${var.nodegroup_name}_${data.aws_subnet.subnet[count.index].availability_zone}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

}


resource "aws_autoscaling_schedule" "eks" {
  count                  = var.is_sandbox && var.desired_size_per_subnet > 0 ? length(var.subnet_ids) : 0
  autoscaling_group_name = aws_autoscaling_group.eks[count.index].name
  scheduled_action_name  = "Scale to zero"
  recurrence             = var.scale_to_zero_cron
  min_size               = local.asg_min_size
  max_size               = local.asg_max_size
  desired_capacity       = 0
}
