# Terragrunt will copy the Terraform configurations specified by the source parameter, along with any files in the
# working directory, into a temporary folder, and execute your Terraform commands in that folder.
terraform {
  source = "../../../../..//compute/eks-ec2"
}

# Include all settings from the root terraform.tfvars file
include {
  path = "${find_in_parent_folders("root.hcl")}"
}

dependencies {
  paths = ["../../../_global/eks-public-s3-bucket"]
}


inputs = {

  # --------------------------------------------------
  # EKS
  # --------------------------------------------------

  eks_cluster_name                           = "qa"
  eks_cluster_version                        = "1.33"
  eks_cluster_cidr_block                     = "10.228.0.0/16"
  eks_cluster_zones                          = 2
  eks_cluster_log_types                      = ["api", "authenticator", "scheduler", "controllerManager"]

  eks_addon_vpccni_prefix_delegation_enabled = true
  eks_addon_most_recent                      = false
  # renovate: eksAddonsFilter={"kubernetesVersion":"1.33","addonName":"vpc-cni"}
  eks_addon_vpccni_version_override = "v1.19.6-eksbuild.7"
  # renovate: eksAddonsFilter={"kubernetesVersion":"1.33","addonName":"coredns"}
  eks_addon_coredns_version_override = "v1.12.2-eksbuild.4"
  # renovate: eksAddonsFilter={"kubernetesVersion":"1.33","addonName":"kube-proxy"}
  eks_addon_kubeproxy_version_override = "v1.33.0-eksbuild.2"
  # renovate: eksAddonsFilter={"kubernetesVersion":"1.33","addonName":"aws-efs-csi-driver"}
  eks_addon_awsefscsidriver_version_override = "v2.1.10-eksbuild.1"
  # renovate: eksAddonsFilter={"kubernetesVersion":"1.33","addonName":"aws-ebs-csi-driver"}
  eks_addon_awsebscsidriver_version_override = "v1.47.0-eksbuild.1"

  enable_worker_nat_gateway                  = true
  use_worker_nat_gateway                     = true

  eks_worker_ssh_ip_whitelist = ["193.9.230.0/24"]
  eks_worker_ssh_public_key   = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2PlxsmewLiLRCQbuATu4yLRsAOMGqaCa/KL3GPo1Wyr19XVVFWseyaVERN1t/xBPlryOikHbfkuNnm8c3mtOop9daEEi2neWMpHqGp/IqHRw5tJiEg50/zauC2kETuG9pLADzs/tVrLlghKHmzv9s6VPEJM7l6hKWF04AdHK2auICRXnOM+by1+gquoDAvL3tytX55Xrx3P+dMB4tpgt/SABVomE6/XiaaxHdntj6pGGl1CYtzC2Md+4K6pXh2mr/pESqXqGxcW6HBUhwYhDEdm1ZEg3WLaFZ2kTjCvIUCPgA7Zo3cq8NQbjw6rsnrqTrsCG7OIRakrWFlxetKvZluVARaJscnQov98iwS7+owGKf+eJ9Fg6O26ewHKX0zuxU/33l1KqGdfGEVfsA+CzRSKr9yj1BvCzqf4yaESZT/D0uNDCWPTC0pmJ02F1/XUvOnDl7cihHHTXTlwRnXBKz7X8xpwUtb/K+yyvUI4KcRmcmxRUFxl3SVuaaXJ1avfb0FOGB07ZO47OQ1/gCkHmzYpu5YtBeVwOAfxOsCX3k1Svqhvpbwg6KdkdSvouXdMFqQ10rtF65E8yiX0pHnDHC3Vgpa/Nw5hZ0fH1MTRDIDf2ZTciARkzGrUtYPu9Yi68X9bcLgfn6cA6HNp/UGhm6YvpoKrkZgX2yJIkphALqTQ== qa"
  eks_k8s_auth_api_version    = "client.authentication.k8s.io/v1beta1"

  eks_is_sandbox = true
  # Since rebooting the cluster after inactivity at the moment requires first
  # running `terragrunt apply -target=module.eks_cluster` the QA cluster is
  # excluded from the inactivity clean up on this step.
  enable_inactivity_cleanup = false

  # --------------------------------------------------
  # Managed nodes
  # --------------------------------------------------

  # Find compatible AMI
  # aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.32/amazon-linux-2023/x86_64/standard/recommended/image_id --region eu-west-1 --query "Parameter.Value" --output text
  eks_managed_nodegroups = {
    "general" = {
      instance_types          = ["m6a.xlarge"]
      disk_type               = "gp3"
      desired_size_per_subnet = 1
      # This comment configures the renovate bot to automatically update this variable:
      # amiFilter=[{"Name":"owner-id","Values":["602401143452"]},{"Name":"name","Values":["amazon-eks-node-al2023-x86_64-standard-1.33-*"]}]
      # currentImageName=amazon-eks-node-al2023-x86_64-standard-1.33-v20250807
      ami_id             = "ami-055dde98016871df5"
      availability_zones         = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
      max_unavailable_percentage = 50
      kube_memory                = "1024Mi"
      kube_cpu                   = "500m"
      sys_memory                 = "768Mi"
      sys_cpu                    = "300m"
    }
    "observability" = {
      instance_types          = ["t3.large"]
      disk_type               = "gp3"
      desired_size_per_subnet = 1
      max_unavailable         = 1
      # This comment configures the renovate bot to automatically update this variable:
      # amiFilter=[{"Name":"owner-id","Values":["602401143452"]},{"Name":"name","Values":["amazon-eks-node-al2023-x86_64-standard-1.33-*"]}]
      # currentImageName=amazon-eks-node-al2023-x86_64-standard-1.33-v20250807
      ami_id             = "ami-055dde98016871df5"
      availability_zones = ["eu-west-1c"]
      taints = [
        {
          key    = "observability.dfds"
          effect = "NO_SCHEDULE"
        }
      ]
      labels = {
        dedicated = "observability"
      }
      max_pods      = 30
      kube_memory   = "585Mi"
      kube_cpu      = "90m"
      sys_memory    = "585Mi"
      sys_cpu       = "90m"
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
