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

  eks_cluster_name          = "qa"
  eks_cluster_version       = "1.36"
  eks_cluster_cidr_block    = "10.228.0.0/16"
  eks_cluster_zones         = 2
  eks_cluster_log_types     = ["api", "authenticator", "scheduler", "controllerManager"]
  eks_addon_most_recent     = true
  eks_is_sandbox            = true
  enable_worker_nat_gateway = true
  use_worker_nat_gateway    = true
  eks_k8s_auth_api_version  = "client.authentication.k8s.io/v1beta1"

  # --------------------------------------------------
  # Managed nodes
  # --------------------------------------------------

  # Find compatible AMI
  # aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.32/amazon-linux-2023/x86_64/standard/recommended/image_id --region eu-west-1 --query "Parameter.Value" --output text
  eks_managed_nodegroups = {
    "general" = {
      instance_types          = ["m6a.xlarge"]
      desired_size_per_subnet = 1
      # This comment configures the renovate bot to automatically update this variable:
      # amiFilter=[{"Name":"owner-id","Values":["602401143452"]},{"Name":"name","Values":["amazon-eks-node-al2023-x86_64-standard-1.36-*"]}]
      # currentImageName=amazon-eks-node-al2023-x86_64-standard-1.36-v20260810
      ami_id                     = "ami-0a46c14d6d0cd41d6"
      availability_zones         = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
      max_unavailable_percentage = 50
      labels = {
        "karpenter.sh/controller" = "true" # required for Karpenter
      }
    }
    "observability" = {
      instance_types          = ["t3.large"]
      desired_size_per_subnet = 1
      max_unavailable         = 1
      # This comment configures the renovate bot to automatically update this variable:
      # amiFilter=[{"Name":"owner-id","Values":["602401143452"]},{"Name":"name","Values":["amazon-eks-node-al2023-x86_64-standard-1.36-*"]}]
      # currentImageName=amazon-eks-node-al2023-x86_64-standard-1.36-v20260810
      ami_id             = "ami-0a46c14d6d0cd41d6"
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
    }
  }

  # --------------------------------------------------
  # Restore Blaster Configmap
  # --------------------------------------------------

  blaster_configmap_bucket = "dfds-qa-k8s-configmap"
}
