locals {
  /*
  https://kubernetes.io/docs/concepts/configuration/taint-and-toleration/#example-use-cases
  https://aws.amazon.com/blogs/opensource/improvements-eks-worker-node-provisioning/
  */
  bootstrap_extra_args = length(var.kubelet_extra_args) >= 1 ? "--kubelet-extra-args '${var.kubelet_extra_args}'" : ""
}

locals {
  /*
  EKS currently documents this required userdata for EKS worker nodes to
  properly configure Kubernetes applications on the EC2 instance.
  We utilize a Terraform local here to simplify Base64 encoding this
  information into the AutoScaling Launch Configuration.
  More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
  */

  worker-node-userdata = <<USERDATA
#!/bin/sh
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${var.eks_endpoint}' --b64-cluster-ca '${var.eks_certificate_authority}' ${local.bootstrap_extra_args} '${var.cluster_name}'

echo fs.inotify.max_user_watches=${var.worker_inotify_max_user_watches} | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
USERDATA

  worker-node-userdata-cw-agent = <<USERDATA
#!/bin/sh
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${var.eks_endpoint}' --b64-cluster-ca '${var.eks_certificate_authority}' ${local.bootstrap_extra_args} '${var.cluster_name}'

echo fs.inotify.max_user_watches=${var.worker_inotify_max_user_watches} | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

mkdir /var/cloudwatch/

wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm -P /var/cloudwatch
sudo rpm -U /var/cloudwatch/amazon-cloudwatch-agent.rpm

sudo aws s3 cp s3://${var.cloudwatch_agent_config_bucket} /var/cloudwatch/ --recursive
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/var/cloudwatch/${var.cloudwatch_agent_config_file} -s
USERDATA

}

resource "aws_launch_configuration" "eks" {
  count                       = signum(length(var.instance_types))
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

resource "aws_autoscaling_group" "eks" {
  # Generate local map (subnet_id = az), instead of typing out several clunky lookups into same source
  # Since we're using for_each subnet, instead of count, in main module, only pass subnets if instance type specified
  count                = length(var.instance_types) > 0 ? length(var.subnet_ids) : 0
  name                 = "eks-${var.cluster_name}-${var.nodegroup_name}_${data.aws_subnet.subnet[count.index].availability_zone}"
  launch_configuration = try(aws_launch_configuration.eks[0].id, ["NA"])
  availability_zones   = toset([data.aws_subnet.subnet[count.index].availability_zone])
  min_size             = var.min_size_per_subnet
  max_size             = var.max_size_per_subnet
  desired_capacity     = var.desired_size_per_subnet
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

}

