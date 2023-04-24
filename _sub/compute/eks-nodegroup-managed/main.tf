resource "aws_launch_template" "eks" {
  count = signum(var.desired_size_per_subnet)

  image_id      = local.node_ami
  instance_type = element(var.instance_types, 0)
  name_prefix   = "eks-${var.cluster_name}-${var.nodegroup_name}-"
  # Make sure to update the max pod values in the template below using the script
  # `src/produce-eni-max-pods.sh` when updating the EKS VPC CNI addon.
  user_data = base64encode(templatefile("${path.module}/user-data.sh.tftpl", {
    eks_endpoint : var.eks_endpoint,
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

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = var.disk_size
      volume_type           = var.disk_type
      delete_on_termination = true
    }
  }
  monitoring {
    enabled = true
  }
}

resource "aws_eks_node_group" "group" {
  count           = signum(var.desired_size_per_subnet)
  cluster_name    = var.cluster_name
  node_group_name = var.nodegroup_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids
  capacity_type   = var.use_spot_instances ? "SPOT" : "ON_DEMAND"

  dynamic "taint" {
    for_each = var.taints
    content {
      key    = taint.value["key"]
      value  = taint.value["value"]
      effect = taint.value["effect"]
    }
  }

  labels = var.labels

  launch_template {
    id      = aws_launch_template.eks[0].id
    version = aws_launch_template.eks[0].latest_version
  }

  dynamic "update_config" {
    for_each = var.max_unavailable != null ? [var.max_unavailable] : []
    content {
      max_unavailable = update_config.value
    }
  }

  dynamic "update_config" {
    for_each = var.max_unavailable_percentage != null ? [var.max_unavailable_percentage] : []
    content {
      max_unavailable_percentage = update_config.value
    }
  }

  scaling_config {
    desired_size = local.asg_desired_size
    max_size     = local.asg_max_size
    min_size     = local.asg_min_size
  }
}

resource "aws_autoscaling_schedule" "eks" {
  count                  = var.is_sandbox ? signum(var.desired_size_per_subnet) : 0
  autoscaling_group_name = aws_eks_node_group.group[0].resources[0].autoscaling_groups[0].name
  scheduled_action_name  = "Scale to zero"
  recurrence             = var.scale_to_zero_cron
  min_size               = local.asg_min_size
  max_size               = local.asg_max_size
  desired_capacity       = 0
}
