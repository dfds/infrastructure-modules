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
/etc/eks/bootstrap.sh --apiserver-endpoint '${var.eks_endpoint}' --container-runtime '${var.container_runtime}' --b64-cluster-ca '${var.eks_certificate_authority}' ${local.bootstrap_extra_args} '${var.cluster_name}'

echo fs.inotify.max_user_watches=${var.worker_inotify_max_user_watches} | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
USERDATA

  worker-node-userdata-cw-agent = <<USERDATA
#!/bin/sh
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint '${var.eks_endpoint}' --container-runtime '${var.container_runtime}' --b64-cluster-ca '${var.eks_certificate_authority}' ${local.bootstrap_extra_args} '${var.cluster_name}'

echo fs.inotify.max_user_watches=${var.worker_inotify_max_user_watches} | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

mkdir /var/cloudwatch/

wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm -P /var/cloudwatch
sudo rpm -U /var/cloudwatch/amazon-cloudwatch-agent.rpm

sudo aws s3 cp s3://${var.cloudwatch_agent_config_bucket} /var/cloudwatch/ --recursive
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/var/cloudwatch/${var.cloudwatch_agent_config_file} -s
USERDATA

}
