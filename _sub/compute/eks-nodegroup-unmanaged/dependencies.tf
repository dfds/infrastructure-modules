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

  # TODO(emil): make configurable, use a template perhaps
  # TODO(emil): pass in the addon version

  # Make sure to update the max pod values below using the script
  # `src/produce-eni-max-pods.sh` when updating the EKS VPC CNI addon.
  worker-node-userdata = <<USERDATA
#!/bin/sh
set -o xtrace

cat <<EOT > /etc/eks/eni-max-pods.txt
m5a.12xlarge 3714
m5a.16xlarge 11762
m5a.24xlarge 11762
m5a.2xlarge 898
m5a.4xlarge 3714
m5a.8xlarge 3714
m5a.large 434
m5a.xlarge 898
m6a.12xlarge 3714
m6a.16xlarge 11762
m6a.24xlarge 11762
m6a.2xlarge 898
m6a.32xlarge 11762
m6a.48xlarge 11762
m6a.4xlarge 3714
m6a.8xlarge 3714
m6a.large 434
m6a.metal 737
m6a.xlarge 898
t3.2xlarge 898
t3.large 530
t3.medium 242
t3.micro 34
t3.nano 34
t3.small 146
t3.xlarge 898
t3a.2xlarge 898
t3a.large 530
t3a.medium 242
t3a.micro 34
t3a.nano 34
t3a.small 98
t3a.xlarge 898
EOT

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
