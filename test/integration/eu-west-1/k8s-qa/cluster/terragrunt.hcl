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

  eks_is_sandbox                             = true
  eks_cluster_name                           = "qa"
  eks_cluster_version                        = "1.25"
  eks_addon_vpccni_prefix_delegation_enabled = false

  eks_worker_ssh_ip_whitelist = ["193.9.230.100/32"]
  eks_worker_ssh_public_key   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDS85QojLMO8eI5ArwburDpVthEZmW3IVs4/nmv7YnDMgs+ucJmW/etm7MlkRDvWphH4X/6mSGGmylJq7vUIn5rHMG0KTFxg06G2ZJ0zS6ryQ89tDLA9LXhD3q//TzXDFJ4ztjcSyxL1fSW44Lpmt7l7wWHdgrMaP3db2TRYOKY2/0iC22TwQKjTSGku59sFmv3XkLVBehO3fFOXcbLChZ4+maPMmgJDUyYMVSVZNJ2YsjFHHeaYClaN0az0Agcab2HIZMZh0Vv08ro0Se5ZBUjyfoPuDe3WjutkivePajG710k10vSOx6X5CHO3bZvQEBA8klCY58Xp2XrzSChNZhP eks-deploy-hellman"
  eks_k8s_auth_api_version    = "client.authentication.k8s.io/v1beta1"


  # --------------------------------------------------
  # Unmanaged nodes
  # --------------------------------------------------

  eks_worker_subnets = ["10.0.16.0/21", "10.0.24.0/21", "10.0.32.0/21"]
  # This comment configures the renovate bot to automatically update this variable:
  # amiFilter=[{"Name":"owner-id","Values":["602401143452"]},{"Name":"name","Values":["amazon-eks-node-1.25-*"]}]
  # currentImageName=amazon-eks-node-1.25-v20230304
  eks_nodegroup2_ami_id                  = "ami-04dc8cdc2e948f054"
  eks_nodegroup2_instance_types          = ["m5a.xlarge"]
  eks_nodegroup2_container_runtime       = "containerd"
  eks_nodegroup2_desired_size_per_subnet = 1
  eks_nodegroup2_kubelet_extra_args      = "--node-labels=nodegroup=ng2"

  # --------------------------------------------------
  # Managed nodes
  # --------------------------------------------------

  eks_managed_worker_subnets = [
    {
      availability_zone = "eu-west-1a",
      subnet_cidr       = "10.0.64.0/18",
      # Subnetting:
      # https://www.davidc.net/sites/default/subnets/subnets.html?network=10.0.64.0&mask=18&division=15.f051
      prefix_reservations_cidrs = [
        "10.0.68.0/22",
        "10.0.72.0/21",
        "10.0.80.0/20",
        "10.0.96.0/20",
        "10.0.112.0/21",
        "10.0.120.0/22"
      ],
    },
    {
      availability_zone = "eu-west-1b",
      subnet_cidr       = "10.0.128.0/18",
      # Subnetting:
      # https://www.davidc.net/sites/default/subnets/subnets.html?network=10.0.128.0&mask=18&division=15.f051
      prefix_reservations_cidrs = [
        "10.0.132.0/22",
        "10.0.136.0/21",
        "10.0.144.0/20",
        "10.0.160.0/20",
        "10.0.176.0/21",
        "10.0.184.0/22"
      ],
    },
    {
      availability_zone = "eu-west-1c",
      subnet_cidr       = "10.0.192.0/18",
      # Subnetting:
      # https://www.davidc.net/sites/default/subnets/subnets.html?network=10.0.192.0&mask=18&division=15.f051
      prefix_reservations_cidrs = [
        "10.0.196.0/22",
        "10.0.200.0/21",
        "10.0.208.0/20",
        "10.0.224.0/20",
        "10.0.240.0/21",
        "10.0.248.0/22",
      ],
    }
  ]

  eks_managed_nodegroups = [
    {
      name                    = "general"
      instance_types          = ["m5a.xlarge"]
      desired_size_per_subnet = 1
      # This comment configures the renovate bot to automatically update this variable:
      # amiFilter=[{"Name":"owner-id","Values":["602401143452"]},{"Name":"name","Values":["amazon-eks-node-1.25-*"]}]
      # currentImageName=amazon-eks-node-1.25-v20230304
      ami_id             = "ami-04dc8cdc2e948f054"
      availability_zones = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
      # TODO(emil): The kubelet memory reservation here is set as if prefix delegation
      # is enabled and the max pods limit has been raised to 110, eventhough without
      # enabling the max pod limit is 58 and the memory reservation would be lower. This
      # override should be removed when prefix delegation is enabled.
      kubelet_extra_args = "--max-pods=58 --kube-reserved=memory=1465Mi,cpu=80m"
      max_unavailable_percentage    = 50
    },
    {
      name                    = "monitoring"
      instance_types          = ["m5a.xlarge"]
      desired_size_per_subnet = 1
      # This comment configures the renovate bot to automatically update this variable:
      # amiFilter=[{"Name":"owner-id","Values":["602401143452"]},{"Name":"name","Values":["amazon-eks-node-1.25-*"]}]
      # currentImageName=amazon-eks-node-1.25-v20230304
      ami_id             = "ami-04dc8cdc2e948f054"
      availability_zones = ["eu-west-1b"]
      kubelet_extra_args = "--max-pods=30 --kube-reserved=memory=585Mi,cpu=80m"
      max_unavailable    = 1
      taints = [
        {
          key    = "monitoring.dfds"
          effect = "NO_SCHEDULE"
        }
      ]
      labels = {
        dedicated = "monitoring"
      }
    },
  ]

  # --------------------------------------------------
  # Restore Blaster Configmap
  # --------------------------------------------------

  blaster_configmap_bucket = "dfds-qa-k8s-configmap"

}
