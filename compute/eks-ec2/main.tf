# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend          "s3"             {}
  required_version = "~> 0.11.7"
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 2.00"

  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

provider "kubernetes" {
  config_path = "${local.kubeconfig_path}"
}

# --------------------------------------------------
# EKS Cluster
# --------------------------------------------------

module "eks_cluster" {
  source          = "../../_sub/compute/eks-cluster"
  cluster_name    = "${var.eks_cluster_name}"
  cluster_version = "${var.eks_cluster_version}"
}

module "eks_workers" {
  source                          = "../../_sub/compute/eks-workers"
  cluster_name                    = "${var.eks_cluster_name}"
  cluster_version                 = "${var.eks_cluster_version}"
  eks_endpoint                    = "${module.eks_cluster.eks_endpoint}"
  eks_certificate_authority       = "${module.eks_cluster.eks_certificate_authority}"
  worker_instance_max_count       = "${var.eks_worker_instance_max_count}"
  worker_instance_min_count       = "${var.eks_worker_instance_min_count}"
  worker_instance_type            = "${var.eks_worker_instance_type}"
  worker_instance_storage_size    = "${var.eks_worker_instance_storage_size}"
  worker_inotify_max_user_watches = "${var.eks_worker_inotify_max_user_watches}"
  autoscale_security_group        = "${module.eks_cluster.autoscale_security_group}"
  vpc_id                          = "${module.eks_cluster.vpc_id}"
  subnet_ids                      = "${module.eks_cluster.subnet_ids}"
  enable_ssh                      = "${var.eks_worker_ssh_enable}"
  public_key                      = "${var.eks_worker_ssh_public_key}"
  cloudwatch_agent_config_bucket  = "${var.eks_worker_cloudwatch_agent_config_deploy ? module.cloudwatch_agent_config_bucket.bucket_name : "none"}"
  cloudwatch_agent_config_file    = "${var.eks_worker_cloudwatch_agent_config_file}"
  cloudwatch_agent_enabled        = "${var.eks_worker_cloudwatch_agent_config_deploy}"
}

module "blaster_configmap_bucket" {
  source    = "../../_sub/storage/s3-bucket"
  deploy    = "${var.blaster_configmap_deploy}"
  s3_bucket = "${var.blaster_configmap_bucket}"
}

module "eks_heptio" {
  source                      = "../../_sub/compute/eks-heptio"
  aws_assume_role_arn         = "${var.aws_assume_role_arn}"
  cluster_name                = "${var.eks_cluster_name}"
  kubeconfig_path             = "${local.kubeconfig_path}"
  eks_endpoint                = "${module.eks_cluster.eks_endpoint}"
  eks_certificate_authority   = "${module.eks_cluster.eks_certificate_authority}"
  eks_role_arn                = "${module.eks_workers.worker_role}"
  blaster_configmap_apply     = "${var.blaster_configmap_deploy}"
  blaster_configmap_s3_bucket = "${module.blaster_configmap_bucket.bucket_name}"
  blaster_configmap_key       = "configmap_${module.eks_heptio.cluster_name}_blaster.yml"
}

module "eks_addons" {
  source          = "../../_sub/compute/eks-addons"
  kubeconfig_path = "${module.eks_heptio.kubeconfig_path}"
  cluster_version = "${var.eks_cluster_version}"
}

module "param_store_admin_kube_config" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/eks/${var.eks_cluster_name}/admin"
  key_description = "Kube config file for intial admin"
  key_value       = "${module.eks_heptio.admin_configfile}"
}

module "param_store_default_kube_config" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/eks/${var.eks_cluster_name}/default_user"
  key_description = "Kube config file for general users"
  key_value       = "${module.eks_heptio.user_configfile}"
}

module "cloudwatch_agent_config_bucket" {
  source    = "../../_sub/storage/s3-bucket"
  deploy    = "${var.eks_worker_cloudwatch_agent_config_deploy}"
  s3_bucket = "${var.eks_cluster_name}-cl-agent-config"
}
