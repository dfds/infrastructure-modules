resource "aws_launch_template" "eks" {
  count = signum(var.desired_size_per_subnet)

  image_id      = local.node_ami
  instance_type = element(var.instance_types, 0)
  name_prefix   = "eks-${var.cluster_name}-${var.nodegroup_name}-"
  # Make sure to update the max pod values in the template below using the script
  # `src/produce-eni-max-pods.sh` when updating the EKS VPC CNI addon.
  user_data = base64encode(templatefile("${path.module}/user-data.sh.tftpl", {
    eks_endpoint : var.eks_endpoint,
    container_runtime : var.container_runtime,
    eks_certificate_authority : var.eks_certificate_authority,
    cluster_name : var.cluster_name,
    bootstrap_extra_args : local.bootstrap_extra_args,
    worker_inotify_max_user_watches : var.worker_inotify_max_user_watches,
    cloudwatch_agent_enabled : var.cloudwatch_agent_enabled,
    cloudwatch_agent_config_bucket : var.cloudwatch_agent_config_bucket,
    cloudwatch_agent_config_file : var.cloudwatch_agent_config_file,
    vpc_cni_prefix_delegation_enabled : var.vpc_cni_prefix_delegation_enabled,
  }))
  key_name               = var.ec2_ssh_key
  update_default_version = true

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = var.security_groups
  }

  iam_instance_profile {
    name = var.iam_instance_profile
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.disk_size
      volume_type           = "gp2"
      delete_on_termination = true
    }
  }
  monitoring {
    enabled = true
  }
}

# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/placement-groups.html
resource "aws_placement_group" "cluster" {
  name     = "eks_${var.cluster_name}_${var.nodegroup_name}"
  strategy = "cluster"
}


locals {
  asg_min_size = 0                               # Allow scaling an ASG to zero, e.g. for maintenance og dialing down sandbox clusters at night
  asg_max_size = 2 * var.desired_size_per_subnet # Allows node roll-over script to double the instance count, to roll-over all nodes in an ASG in one operation
}


resource "aws_autoscaling_group" "eks" {
  count = var.desired_size_per_subnet > 0 ? length(var.subnet_ids) : 0
  name  = "eks-${var.cluster_name}-${var.nodegroup_name}_${data.aws_subnet.subnet[count.index].availability_zone}"
  launch_template {
    id      = try(aws_launch_template.eks[0].id, ["NA"])
    version = aws_launch_template.eks[0].latest_version
  }
  min_size            = local.asg_min_size
  max_size            = local.asg_max_size
  desired_capacity    = var.desired_size_per_subnet
  vpc_zone_identifier = toset([data.aws_subnet.subnet[count.index].id])

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

  lifecycle {
    ignore_changes = [target_group_arns]
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
