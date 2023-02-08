# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../..//compute/eks-ec2"
}

# Include all settings from the root terraform.tfvars file
include {
  path = "${find_in_parent_folders()}"
}

dependencies {
  paths = ["../../../_global/eks-public-s3-bucket"]
}


inputs = {

  # --------------------------------------------------
  # EKS
  # --------------------------------------------------

  eks_is_sandbox      = true
  eks_cluster_name    = "qa"
  eks_cluster_version = "1.23"

  eks_worker_subnets          = ["10.0.16.0/21", "10.0.24.0/21", "10.0.32.0/21"]
  eks_worker_ssh_ip_whitelist = ["193.9.230.100/32"]
  eks_worker_ssh_public_key   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDS85QojLMO8eI5ArwburDpVthEZmW3IVs4/nmv7YnDMgs+ucJmW/etm7MlkRDvWphH4X/6mSGGmylJq7vUIn5rHMG0KTFxg06G2ZJ0zS6ryQ89tDLA9LXhD3q//TzXDFJ4ztjcSyxL1fSW44Lpmt7l7wWHdgrMaP3db2TRYOKY2/0iC22TwQKjTSGku59sFmv3XkLVBehO3fFOXcbLChZ4+maPMmgJDUyYMVSVZNJ2YsjFHHeaYClaN0az0Agcab2HIZMZh0Vv08ro0Se5ZBUjyfoPuDe3WjutkivePajG710k10vSOx6X5CHO3bZvQEBA8klCY58Xp2XrzSChNZhP eks-deploy-hellman"

  eks_nodegroup2_ami_id                  = "ami-0b5476968dbc19ad9"
  eks_nodegroup2_instance_types          = ["m5a.xlarge"]
  eks_nodegroup2_container_runtime          = "containerd"
  eks_nodegroup2_desired_size_per_subnet = 1
  eks_nodegroup2_kubelet_extra_args      = "--node-labels=nodegroup=ng2"

  eks_k8s_auth_api_version = "client.authentication.k8s.io/v1beta1"

  # --------------------------------------------------
  # Restore Blaster Configmap
  # --------------------------------------------------

  blaster_configmap_bucket = "dfds-qa-k8s-configmap"

}
