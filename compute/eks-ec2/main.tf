# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

provider "kubernetes" {
  host                   = module.eks_cluster.eks_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.eks_certificate_authority)

  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      var.eks_cluster_name,
      "--role-arn",
      var.aws_assume_role_arn,
    ]
  }
}


# --------------------------------------------------
# EKS Cluster
# --------------------------------------------------

module "eks_cluster" {
  source             = "../../_sub/compute/eks-cluster"
  cluster_name       = var.eks_cluster_name
  cluster_version    = var.eks_cluster_version
  cluster_zones      = var.eks_cluster_zones
  log_types          = var.eks_cluster_log_types
  log_retention_days = var.eks_cluster_log_retention_days
}

module "eks_internet_gateway" {
  source = "../../_sub/network/internet-gateway"
  name   = "eks-${var.eks_cluster_name}"
  vpc_id = module.eks_cluster.vpc_id
}

module "eks_route_table" {
  source     = "../../_sub/network/route-table"
  name       = "eks-${var.eks_cluster_name}-subnet"
  vpc_id     = module.eks_cluster.vpc_id
  gateway_id = module.eks_internet_gateway.id
}

module "eks_workers_subnet" {
  source       = "../../_sub/network/vpc-subnet-eks"
  deploy       = length(var.eks_worker_subnets) >= 1 ? true : false
  name         = "eks-${var.eks_cluster_name}"
  cluster_name = var.eks_cluster_name
  vpc_id       = module.eks_cluster.vpc_id
  subnets      = var.eks_worker_subnets
}

module "eks_workers_keypair" {
  source     = "../../_sub/compute/ec2-keypair"
  name       = "eks-${var.eks_cluster_name}-workers"
  public_key = var.eks_worker_ssh_public_key
}

# module "eks_workers_iam_role" {
#   source = "../../_sub/security/iam-role"
# }

module "eks_workers_security_group" {
  source                   = "../../_sub/network/security-group-eks-node"
  vpc_id                   = module.eks_cluster.vpc_id
  cluster_name             = var.eks_cluster_name
  autoscale_security_group = module.eks_cluster.autoscale_security_group
  ssh_ip_whitelist         = var.eks_worker_ssh_ip_whitelist
}

# Is actually only IAM at this point
module "eks_workers" {
  source                         = "../../_sub/compute/eks-workers"
  cluster_name                   = var.eks_cluster_name
  cloudwatch_agent_config_bucket = var.eks_worker_cloudwatch_agent_config_deploy ? module.cloudwatch_agent_config_bucket.bucket_name : "none"
}

module "eks_workers_route_table_assoc" {
  source = "../../_sub/network/route-table-assoc"

  # count_assoc          = "${length(var.eks_cluster_zones)}"    # need to pass count explicitly, otherwise: value of 'count' cannot be computed
  subnet_ids     = module.eks_cluster.subnet_ids
  route_table_id = module.eks_route_table.id
}

# Misleading - is actually for all node groups. Might even not need both this, and eks_workers_route_table_assoc?
module "eks_nodegroup1_route_table_assoc" {
  source = "../../_sub/network/route-table-assoc"

  # count          = "${length(var.eks_worker_subnets)}"       # need to pass count explicitly, otherwise: value of 'count' cannot be computed
  subnet_ids     = module.eks_workers_subnet.subnet_ids
  route_table_id = module.eks_route_table.id
}

/*
TO DO:
Move worker/node IAM role (currently in workers) to separate sub
Feature toggle nodegroups
 - Test 0, 1, more-subnets-than-AZs
*/

# --------------------------------------------------
# NODE GROUP 1
# --------------------------------------------------

module "eks_nodegroup1_workers" {
  source = "../../_sub/compute/eks-nodegroup-unmanaged"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version
  is_sandbox      = var.eks_is_sandbox
  nodegroup_name  = "ng1"

  # node_role_arn           = "${module.eks_workers_iam_role.arn}"
  iam_instance_profile    = module.eks_workers.iam_instance_profile_name
  security_groups         = [module.eks_workers_security_group.id]
  desired_size_per_subnet = var.eks_nodegroup1_desired_size_per_subnet
  scale_to_zero_cron      = var.eks_worker_scale_to_zero_cron
  subnet_ids              = module.eks_workers_subnet.subnet_ids
  disk_size               = var.eks_nodegroup1_disk_size
  instance_types          = var.eks_nodegroup1_instance_types
  gpu_ami                 = var.eks_nodegroup1_gpu_ami
  ec2_ssh_key             = module.eks_workers_keypair.key_name

  kubelet_extra_args = var.eks_nodegroup1_kubelet_extra_args

  cloudwatch_agent_config_bucket  = var.eks_worker_cloudwatch_agent_config_deploy ? module.cloudwatch_agent_config_bucket.bucket_name : "none"
  cloudwatch_agent_config_file    = var.eks_worker_cloudwatch_agent_config_file
  cloudwatch_agent_enabled        = var.eks_worker_cloudwatch_agent_config_deploy
  eks_endpoint                    = module.eks_cluster.eks_endpoint
  eks_certificate_authority       = module.eks_cluster.eks_certificate_authority
  worker_inotify_max_user_watches = var.eks_worker_inotify_max_user_watches
  autoscale_security_group        = module.eks_cluster.autoscale_security_group
}


# --------------------------------------------------
# NODE GROUP 2
# --------------------------------------------------

module "eks_nodegroup2_workers" {
  source = "../../_sub/compute/eks-nodegroup-unmanaged"

  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version
  is_sandbox      = var.eks_is_sandbox
  nodegroup_name  = "ng2"

  # node_role_arn           = "${module.eks_workers_iam_role.arn}"
  iam_instance_profile    = module.eks_workers.iam_instance_profile_name
  security_groups         = [module.eks_workers_security_group.id]
  desired_size_per_subnet = var.eks_nodegroup2_desired_size_per_subnet
  scale_to_zero_cron      = var.eks_worker_scale_to_zero_cron
  subnet_ids              = module.eks_workers_subnet.subnet_ids
  disk_size               = var.eks_nodegroup2_disk_size
  instance_types          = var.eks_nodegroup2_instance_types
  gpu_ami                 = var.eks_nodegroup2_gpu_ami
  ec2_ssh_key             = module.eks_workers_keypair.key_name

  kubelet_extra_args = var.eks_nodegroup2_kubelet_extra_args

  cloudwatch_agent_config_bucket  = var.eks_worker_cloudwatch_agent_config_deploy ? module.cloudwatch_agent_config_bucket.bucket_name : "none"
  cloudwatch_agent_config_file    = var.eks_worker_cloudwatch_agent_config_file
  cloudwatch_agent_enabled        = var.eks_worker_cloudwatch_agent_config_deploy
  eks_endpoint                    = module.eks_cluster.eks_endpoint
  eks_certificate_authority       = module.eks_cluster.eks_certificate_authority
  worker_inotify_max_user_watches = var.eks_worker_inotify_max_user_watches
  autoscale_security_group        = module.eks_cluster.autoscale_security_group
}


# --------------------------------------------------
# OTHER
# --------------------------------------------------

module "blaster_configmap_bucket" {
  source    = "../../_sub/storage/s3-bucket"
  deploy    = length(var.blaster_configmap_bucket) >= 1 ? true : false
  s3_bucket = var.blaster_configmap_bucket
}

module "eks_heptio" {
  source                      = "../../_sub/compute/eks-heptio"
  cluster_name                = var.eks_cluster_name
  kubeconfig_path             = local.kubeconfig_path
  eks_endpoint                = module.eks_cluster.eks_endpoint
  eks_certificate_authority   = module.eks_cluster.eks_certificate_authority
  eks_role_arn                = module.eks_workers.worker_role
  blaster_configmap_apply     = length(var.blaster_configmap_bucket) >= 1 ? true : false
  blaster_configmap_s3_bucket = module.blaster_configmap_bucket.bucket_name
  blaster_configmap_key       = "configmap_${module.eks_heptio.cluster_name}_blaster.yml"
  aws_assume_role_arn         = var.aws_assume_role_arn
}

module "eks_addons" {
  source                     = "../../_sub/compute/eks-addons"
  depends_on                 = [module.eks_cluster]
  cluster_name               = var.eks_cluster_name
  kubeproxy_version_override = var.eks_addon_kubeproxy_version_override
  coredns_version_override   = var.eks_addon_coredns_version_override
  vpccni_version_override    = var.eks_addon_vpccni_version_override
  cluster_version            = var.eks_cluster_version
}

module "k8s_priority_class" {
  source         = "../../_sub/compute/k8s-priority-class"
  priority_class = local.priority_class
}

module "param_kubeconfig_admin" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/eks/${var.eks_cluster_name}/kubeconfig-admin"
  key_description = "Kube config file for initial admin"
  key_value       = module.eks_heptio.kubeconfig_admin
  tag_createdby   = var.ssm_param_createdby != null ? var.ssm_param_createdby : "eks-ec2"
}

module "param_kubeconfig_saml" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/eks/${var.eks_cluster_name}/kubeconfig-saml"
  key_description = "Kube config file for SAML"
  key_value       = module.eks_heptio.kubeconfig_saml
  tag_createdby   = var.ssm_param_createdby != null ? var.ssm_param_createdby : "eks-ec2"
}

module "eks_s3_public_kubeconfig" {
  source  = "../../_sub/storage/s3-bucket-object"
  deploy  = length(var.eks_public_s3_bucket) >= 1 ? true : false
  bucket  = var.eks_public_s3_bucket
  key     = "kubeconfig/${var.eks_cluster_name}-saml.config"
  content = module.eks_heptio.kubeconfig_saml
  acl     = "public-read"
}

# What is this even needed for?
module "k8s_service_account" {
  source                    = "../../_sub/compute/k8s-service-account"
  cluster_name              = var.eks_cluster_name
  eks_endpoint              = module.eks_cluster.eks_endpoint
  eks_certificate_authority = module.eks_cluster.eks_certificate_authority
  # eks_certificate_authority = base64decode(module.eks_cluster.eks_certificate_authority)
}

module "k8s_service_account_store_secret" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/eks/${var.eks_cluster_name}/deploy_user"
  key_description = "Kube config file for general deployment user"
  key_value       = module.k8s_service_account.deploy_user_config
  tag_createdby   = var.ssm_param_createdby != null ? var.ssm_param_createdby : "eks-ec2"
}

module "cloudwatch_agent_config_bucket" {
  source    = "../../_sub/storage/s3-bucket"
  deploy    = var.eks_worker_cloudwatch_agent_config_deploy
  s3_bucket = "${var.eks_cluster_name}-cl-agent-config"
}


# --------------------------------------------------
# Cluster access
# --------------------------------------------------

module "k8s_cloudengineer_clusterrole_and_binding" {
  source = "../../_sub/compute/k8s-clusterrole"
  name   = "cloud-engineer"
  rules = [
    {
      api_groups = ["*"]
      resources  = ["*"]
      verbs      = ["create", "get", "list", "watch"]
    },
    {
      api_groups = [""]
      resources  = ["pods", "pods/attach", "pods/exec", "pods/portforward", "pods/proxy"]
      verbs      = ["*"]
    },
    {
      api_groups = [""]
      resources  = ["nodes"]
      verbs      = ["patch"]
    }
  ]
}

# --------------------------------------------------
# AWS IAM Open ID Connect Provider
# --------------------------------------------------
module "aws_iam_oidc_provider" {
  source                          = "../../_sub/security/iam-oidc-provider"
  eks_openid_connect_provider_url = module.eks_cluster.eks_openid_connect_provider_url
  eks_cluster_name                = var.eks_cluster_name
}
