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
  eks_cluster_version                        = "1.30"
  eks_cluster_zones                          = 2
  eks_addon_vpccni_prefix_delegation_enabled = true
  eks_addon_most_recent                      = true

  eks_worker_ssh_ip_whitelist = ["193.9.230.0/24"]
  eks_worker_ssh_public_key   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2PlxsmewLiLRCQbuATu4yLRsAOMGqaCa/KL3GPo1Wyr19XVVFWseyaVERN1t/xBPlryOikHbfkuNnm8c3mtOop9daEEi2neWMpHqGp/IqHRw5tJiEg50/zauC2kETuG9pLADzs/tVrLlghKHmzv9s6VPEJM7l6hKWF04AdHK2auICRXnOM+by1+gquoDAvL3tytX55Xrx3P+dMB4tpgt/SABVomE6/XiaaxHdntj6pGGl1CYtzC2Md+4K6pXh2mr/pESqXqGxcW6HBUhwYhDEdm1ZEg3WLaFZ2kTjCvIUCPgA7Zo3cq8NQbjw6rsnrqTrsCG7OIRakrWFlxetKvZluVARaJscnQov98iwS7+owGKf+eJ9Fg6O26ewHKX0zuxU/33l1KqGdfGEVfsA+CzRSKr9yj1BvCzqf4yaESZT/D0uNDCWPTC0pmJ02F1/XUvOnDl7cihHHTXTlwRnXBKz7X8xpwUtb/K+yyvUI4KcRmcmxRUFxl3SVuaaXJ1avfb0FOGB07ZO47OQ1/gCkHmzYpu5YtBeVwOAfxOsCX3k1Svqhvpbwg6KdkdSvouXdMFqQ10rtF65E8yiX0pHnDHC3Vgpa/Nw5hZ0fH1MTRDIDf2ZTciARkzGrUtYPu9Yi68X9bcLgfn6cA6HNp/UGhm6YvpoKrkZgX2yJIkphALqTQ== qa"
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
      # amiFilter=[{"Name":"owner-id","Values":["602401143452"]},{"Name":"name","Values":["amazon-eks-node-al2023-x86_64-standard-1.30-*"]}]
      # currentImageName=amazon-eks-node-al2023-x86_64-standard-1.30-v20240917
      ami_id                     = "ami-090ea8d1ab1887790"
      availability_zones         = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
      max_unavailable_percentage = 50
      is_al2023 = true
    }
    "monitoring" = {
      instance_types          = ["m6a.xlarge"]
      disk_type               = "gp3"
      desired_size_per_subnet = 1
      # This comment configures the renovate bot to automatically update this variable:
      # amiFilter=[{"Name":"owner-id","Values":["602401143452"]},{"Name":"name","Values":["amazon-eks-node-al2023-x86_64-standard-1.30-*"]}]
      # currentImageName=amazon-eks-node-al2023-x86_64-standard-1.30-v20240917
      ami_id             = "ami-090ea8d1ab1887790"
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
      is_al2023 = true
      max_pods = 30
      cpu = "80m"
      memory = "585Mi"
    }
    "observability" = {
      instance_types          = ["t3.large"]
      disk_type               = "gp3"
      desired_size_per_subnet = 1
      max_unavailable         = 1
      # This comment configures the renovate bot to automatically update this variable:
      # amiFilter=[{"Name":"owner-id","Values":["602401143452"]},{"Name":"name","Values":["amazon-eks-node-al2023-x86_64-standard-1.30-*"]}]
      # currentImageName=amazon-eks-node-al2023-x86_64-standard-1.30-v20240917
      ami_id             = "ami-090ea8d1ab1887790"
      availability_zones = ["eu-west-1c"]
      kubelet_extra_args = "--max-pods=30 --kube-reserved=memory=585Mi,cpu=90m"
      taints = [
        {
          key    = "observability.dfds"
          effect = "NO_SCHEDULE"
        }
      ]
      labels = {
        dedicated = "observability"
      }
      is_al2023 = true
      max_pods = 30
      memory = "585Mi"
      cpu = "90m"
    }
    "dataplatform" = {
      instance_types          = ["r6a.2xlarge"]
      disk_type               = "gp3"
      desired_size_per_subnet = 1
      max_unavailable         = 1
      # This comment configures the renovate bot to automatically update this variable:
      # amiFilter=[{"Name":"owner-id","Values":["602401143452"]},{"Name":"name","Values":["amazon-eks-node-al2023-x86_64-standard-1.30-*"]}]
      # currentImageName=amazon-eks-node-al2023-x86_64-standard-1.30-v20240917
      ami_id             = "ami-090ea8d1ab1887790"
      availability_zones = ["eu-west-1a", "eu-west-1b"]
      taints = [
        {
          key    = "dataplatform.dfds"
          effect = "NO_SCHEDULE"
        }
      ]
      labels = {
        dedicated = "dataplatform"
      }
      is_al2023 = true
    }
  }

  # --------------------------------------------------
  # GPU workloads
  # --------------------------------------------------

  deploy_nvidia_device_plugin = false
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
  create_nvidia_namespace = false

  # --------------------------------------------------
  # Restore Blaster Configmap
  # --------------------------------------------------

  blaster_configmap_bucket = "dfds-qa-k8s-configmap"

}
