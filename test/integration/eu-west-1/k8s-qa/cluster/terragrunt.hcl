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

  eks_cluster_name                           = "qa"
  eks_cluster_version                        = "1.29"
  eks_cluster_zones                          = 2
  eks_addon_vpccni_prefix_delegation_enabled = true
  eks_addon_most_recent                      = true

  eks_worker_ssh_ip_whitelist = ["193.9.230.0/24"]
  eks_worker_ssh_public_key   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDS85QojLMO8eI5ArwburDpVthEZmW3IVs4/nmv7YnDMgs+ucJmW/etm7MlkRDvWphH4X/6mSGGmylJq7vUIn5rHMG0KTFxg06G2ZJ0zS6ryQ89tDLA9LXhD3q//TzXDFJ4ztjcSyxL1fSW44Lpmt7l7wWHdgrMaP3db2TRYOKY2/0iC22TwQKjTSGku59sFmv3XkLVBehO3fFOXcbLChZ4+maPMmgJDUyYMVSVZNJ2YsjFHHeaYClaN0az0Agcab2HIZMZh0Vv08ro0Se5ZBUjyfoPuDe3WjutkivePajG710k10vSOx6X5CHO3bZvQEBA8klCY58Xp2XrzSChNZhP eks-deploy-hellman"
  eks_k8s_auth_api_version    = "client.authentication.k8s.io/v1beta1"

  eks_is_sandbox = true
  # Since rebooting the cluster after inactivity at the moment requires first
  # running `terragrunt apply -target=module.eks_cluster` the QA cluster is
  # excluded from the inactivity clean up on this step.
  disable_inactivity_cleanup = true

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

  # Find compatible AMI
  # aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.27/amazon-linux-2/recommended/image_id --region eu-west-1 --query "Parameter.Value" --output text
  eks_managed_nodegroups = {
    "general" = {
      instance_types          = ["m6a.xlarge"]
      disk_type               = "gp3"
      desired_size_per_subnet = 1
      # This comment configures the renovate bot to automatically update this variable:
      # amiFilter=[{"Name":"owner-id","Values":["602401143452"]},{"Name":"name","Values":["amazon-eks-node-1.28-*"]}]
      # currentImageName=amazon-eks-node-1.28-v20240213
      ami_id                     = "ami-05877c180274965b1"
      availability_zones         = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
      max_unavailable_percentage = 50
    }
    "monitoring" = {
      instance_types          = ["m6a.xlarge"]
      disk_type               = "gp3"
      desired_size_per_subnet = 1
      # This comment configures the renovate bot to automatically update this variable:
      # amiFilter=[{"Name":"owner-id","Values":["602401143452"]},{"Name":"name","Values":["amazon-eks-node-1.28-*"]}]
      # currentImageName=amazon-eks-node-1.28-v20240213
      ami_id             = "ami-05877c180274965b1"
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
    "gpu" = {
      instance_types = ["g4dn.2xlarge"]
      desired_size_per_subnet = 1
      availability_zones      = ["eu-west-1a"]
      max_unavailable         = 1
      ami_id = "ami-099cf6455e994ad9d"
      taints = [
        {
          key = "dfds.service.gpu"
          effect = "NO_SCHEDULE"
        }
      ]
      labels = {
        dedicated = "gpu"
      }
    }
  }

  # --------------------------------------------------
  # GPU workloads
  # --------------------------------------------------

  deploy_nvidia_device_plugin = true
  nvidia_device_plugin_tolerations = [
    {
      key = "dfds.service.gpu"
      operator = "Exists"
      effect = "NoSchedule"
    }
  ]
  nvidia_device_plugin_affinity = [
    {
      key = "dedicated"
      operator = "In"
      values = ["gpu"]
    }
  ]

  nvidia_chart_version = "0.14.1"
  nvidia_namespace = "nvidia-device-plugin"
  create_nvidia_namespace = true

  # --------------------------------------------------
  # Restore Blaster Configmap
  # --------------------------------------------------

  blaster_configmap_bucket = "dfds-qa-k8s-configmap"

}
