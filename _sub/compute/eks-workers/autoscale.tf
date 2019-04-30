data "aws_ami" "eks-worker" {
  filter {
    name   = "name"
    values = ["amazon-eks-node-1.11-*"]
  }

  most_recent = true
  owners      = ["602401143452"] # Amazon Account ID
}

# EKS currently documents this required userdata for EKS worker nodes to
# properly configure Kubernetes applications on the EC2 instance.
# We utilize a Terraform local here to simplify Base64 encoding this
# information into the AutoScaling Launch Configuration.
# More information: https://docs.aws.amazon.com/eks/latest/userguide/launch-workers.html
locals {
  worker-node-userdata = <<USERDATA
#!/bin/sh
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${var.eks_endpoint}' --b64-cluster-ca '${var.eks_certificate_authority}' '${var.cluster_name}'

USERDATA

  worker-node-userdata-cw-agent = <<USERDATA
#!/bin/sh
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${var.eks_endpoint}' --b64-cluster-ca '${var.eks_certificate_authority}' '${var.cluster_name}'
mkdir  /var/cloudwatch/

wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm -P /var/cloudwatch
sudo rpm -U /var/cloudwatch/amazon-cloudwatch-agent.rpm

sudo aws s3 cp s3://${var.cloudwatch_agent_config_bucket} /var/cloudwatch/ --recursive
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/var/cloudwatch/${var.cloudwatch_agent_config_file} -s

USERDATA

}

resource "aws_launch_configuration" "eks" {
  associate_public_ip_address = true
  iam_instance_profile        = "${aws_iam_instance_profile.eks.name}"
  image_id                    = "${data.aws_ami.eks-worker.id}"
  instance_type               = "${var.worker_instance_type}"
  name_prefix                 = "${var.cluster_name}"
  security_groups             = ["${aws_security_group.eks-node.id}"]
  user_data_base64            = "${var.cloudwatch_agent_enabled ? base64encode(local.worker-node-userdata-cw-agent) : base64encode(local.worker-node-userdata) }"
  key_name                    = "${aws_key_pair.eks-node.key_name}"

  root_block_device = [
    {
      volume_size = "${var.worker_instance_storage_size}"
      volume_type = "gp2"
    },
  ]
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "eks" {
  desired_capacity     = "${var.worker_instance_min_count}"
  launch_configuration = "${aws_launch_configuration.eks.id}"
  max_size             = "${var.worker_instance_max_count}"
  min_size             = "${var.worker_instance_min_count}"
  name                 = "${var.cluster_name}"
  vpc_zone_identifier  = ["${var.subnet_ids}"]
  
  # The following can be set in case of the default health check are not sufficient
  #health_check_grace_period = 5
  #default_cooldown = 15

  tag {
    key                 = "Name"
    value               = "eks-${var.cluster_name}-worker"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }
}

# resource "aws_cloudwatch_dashboard" "main" {
#   dashboard_name = "my-dashboard"

#   dashboard_body = <<EOF
#  {
#     "widgets": [
#         {
#             "type": "metric",
#             "x": 0,
#             "y": 0,
#             "width": 18,
#             "height": 3,
#             "properties": {
#                 "metrics": [
#                     [ "CWAgent", "disk_used_percent", "path", "/", "InstanceId", "i-0d563241a42ddcab1", "AutoScalingGroupName", "kay", "ImageId", "ami-0e82e73403dd69fa3", "InstanceType", "t3.medium", "device", "nvme0n1p1", "fstype", "xfs" ],
#                     [ ".", "disk_used", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", ".", "." ]
#                 ],
#                 "view": "singleValue",
#                 "region": "eu-west-1",
#                 "period": 300,
#                 "title": "Disk usage terraform"
#             }
#         }
#     ]
# }
#  EOF
# }