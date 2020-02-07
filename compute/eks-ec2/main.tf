# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend "s3" {
  }
  # required_version = "~> 0.11.7"
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.43"

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

provider "kubernetes" {
  config_path = local.kubeconfig_path
}

# --------------------------------------------------
# EKS Cluster
# --------------------------------------------------

module "eks_cluster" {
  source          = "../../_sub/compute/eks-cluster"
  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version
  cluster_zones   = var.eks_cluster_zones
}

module "eks_route_table" {
  source       = "../../_sub/network/route-table"
  cluster_name = var.eks_cluster_name
  vpc_id       = module.eks_cluster.vpc_id
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

module "eks_workers" {
  source                          = "../../_sub/compute/eks-workers"
  cluster_name                    = var.eks_cluster_name
  cluster_version                 = var.eks_cluster_version
  eks_endpoint                    = module.eks_cluster.eks_endpoint
  eks_certificate_authority       = module.eks_cluster.eks_certificate_authority
  worker_instance_max_count       = var.eks_worker_instance_max_count
  worker_instance_min_count       = var.eks_worker_instance_min_count
  worker_instance_type            = var.eks_worker_instance_type
  worker_instance_storage_size    = var.eks_worker_instance_storage_size
  worker_inotify_max_user_watches = var.eks_worker_inotify_max_user_watches
  autoscale_security_group        = module.eks_cluster.autoscale_security_group
  subnet_ids                      = module.eks_cluster.subnet_ids
  security_groups                 = [module.eks_workers_security_group.id]
  ec2_ssh_key                     = module.eks_workers_keypair.key_name
  cloudwatch_agent_config_bucket  = var.eks_worker_cloudwatch_agent_config_deploy ? module.cloudwatch_agent_config_bucket.bucket_name : "none"
  cloudwatch_agent_config_file    = var.eks_worker_cloudwatch_agent_config_file
  cloudwatch_agent_enabled        = var.eks_worker_cloudwatch_agent_config_deploy
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

  # deploy                          = "${signum(length(var.eks_nodegroup1_subnets))}"
  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version
  nodegroup_name  = "ng1"

  # node_role_arn           = "${module.eks_workers_iam_role.arn}"
  iam_instance_profile    = module.eks_workers.iam_instance_profile_name
  security_groups         = [module.eks_workers_security_group.id]
  scaling_config_min_size = var.eks_nodegroup1_instance_min_count
  scaling_config_max_size = var.eks_nodegroup1_instance_max_count
  subnet_ids              = module.eks_workers_subnet.subnet_ids
  disk_size               = var.eks_worker_instance_storage_size
  instance_types          = var.eks_nodegroup1_instance_types
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

  # deploy                          = "${signum(length(var.eks_nodegroup1_subnets))}"
  cluster_name    = var.eks_cluster_name
  cluster_version = var.eks_cluster_version
  nodegroup_name  = "ng2"

  # node_role_arn           = "${module.eks_workers_iam_role.arn}"
  iam_instance_profile    = module.eks_workers.iam_instance_profile_name
  security_groups         = [module.eks_workers_security_group.id]
  scaling_config_min_size = var.eks_nodegroup2_instance_min_count
  scaling_config_max_size = var.eks_nodegroup2_instance_max_count
  subnet_ids              = module.eks_workers_subnet.subnet_ids
  disk_size               = var.eks_worker_instance_storage_size
  instance_types          = var.eks_nodegroup2_instance_types
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
  kubeconfig_path            = module.eks_heptio.kubeconfig_path
  cluster_version            = var.eks_cluster_version
  kubeproxy_version_override = var.eks_addon_kubeproxy_version_override
  coredns_version_override   = var.eks_addon_coredns_version_override
  vpccni_version_override    = var.eks_addon_vpccni_version_override
}

module "eks_s3_public_kubeconfig" {
  source  = "../../_sub/storage/s3-bucket-object"
  deploy  = length(var.eks_public_s3_bucket) >= 1 ? true : false
  bucket  = var.eks_public_s3_bucket
  key     = "kubeconfig/${var.eks_cluster_name}-saml.config"
  content = module.eks_heptio.user_configfile
  acl     = "public-read"
}

module "param_store_admin_kube_config" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/eks/${var.eks_cluster_name}/admin"
  key_description = "Kube config file for intial admin"
  key_value       = module.eks_heptio.admin_configfile
}

module "param_store_default_kube_config" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/eks/${var.eks_cluster_name}/default_user"
  key_description = "Kube config file for general users"
  key_value       = module.eks_heptio.user_configfile
}

module "cloudwatch_agent_config_bucket" {
  source    = "../../_sub/storage/s3-bucket"
  deploy    = var.eks_worker_cloudwatch_agent_config_deploy
  s3_bucket = "${var.eks_cluster_name}-cl-agent-config"
}
