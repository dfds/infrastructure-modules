# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend          "s3"             {}
  required_version = "~> 0.11.7"
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.60"

  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.60"
  alias   = "core"
}

provider "azuread" {}

provider "kubernetes" {
  config_path = "${pathexpand("~/.kube/config_${var.eks_cluster_name}")}"
}

# --------------------------------------------------
# EKS Cluster
# --------------------------------------------------

module "eks_cluster" {
  source       = "../../_sub/compute/eks-cluster"
  cluster_name = "${var.eks_cluster_name}"
}

module "eks_workers" {
  source                       = "../../_sub/compute/eks-workers"
  cluster_name                 = "${var.eks_cluster_name}"
  eks_endpoint                 = "${module.eks_cluster.eks_endpoint}"
  eks_certificate_authority    = "${module.eks_cluster.eks_certificate_authority}"
  worker_instance_max_count    = "${var.eks_worker_instance_max_count}"
  worker_instance_min_count    = "${var.eks_worker_instance_min_count}"
  worker_instance_type         = "${var.eks_worker_instance_type}"
  worker_instance_storage_size = "${var.eks_worker_instance_storage_size}"
  autoscale_security_group     = "${module.eks_cluster.autoscale_security_group}"
  vpc_id                       = "${module.eks_cluster.vpc_id}"
  subnet_ids                   = "${module.eks_cluster.subnet_ids}"
  enable_ssh                   = "${var.eks_worker_ssh_enable}"
  public_key                   = "${var.eks_worker_ssh_public_key}"
}

module "eks_heptio" {
  source                    = "../../_sub/compute/eks-heptio"
  aws_assume_role_arn       = "${var.aws_assume_role_arn}"
  cluster_name              = "${var.eks_cluster_name}"
  eks_endpoint              = "${module.eks_cluster.eks_endpoint}"
  eks_certificate_authority = "${module.eks_cluster.eks_certificate_authority}"
  eks_role_arn              = "${module.eks_workers.worker_role}"
}

module "blaster_configmap_bucket" {
  source    = "../../_sub/storage/s3-bucket"
  deploy    = "${var.blaster_configmap_deploy}"
  s3_bucket = "${var.blaster_configmap_bucket}"
}

module "blaster_configmap_apply" {
  source              = "../../_sub/compute/k8s-blaster-configmap"
  deploy              = "${var.blaster_configmap_deploy}"
  aws_assume_role_arn = "${var.aws_assume_role_arn}"
  cluster_name        = "${module.eks_heptio.cluster_name}"
  s3_bucket           = "${module.blaster_configmap_bucket.bucket_name}"
  configmap_key       = "configmap_${module.eks_heptio.cluster_name}_blaster.yml"
}


# --------------------------------------------------
# Traefik
# Depends on a lot of input data from the cluster,
# so it makes sense to keep in this module
# --------------------------------------------------

module "traefik_deploy" {
  source       = "../../_sub/compute/k8s-traefik"
  deploy       = "${var.traefik_deploy}"
  deploy_name  = "${var.traefik_deploy_name}"
  cluster_name = "${module.eks_heptio.cluster_name}"
}

module "traefik_alb_cert" {
  source        = "../../_sub/network/acm-certificate-san"
  deploy        = "${var.traefik_alb_anon_deploy || var.traefik_alb_auth_deploy || var.traefik_nlb_deploy ? 1 : 0}"
  domain_name   = "*.${local.eks_fqdn}"
  dns_zone_name = "${var.workload_dns_zone_name}"
  core_alias    = "${var.traefik_alb_auth_core_alias}"
}

module "traefik_alb_auth_appreg" {
  source            = "../../_sub/security/azure-app-registration"
  deploy            = "${var.traefik_alb_auth_deploy}"
  name              = "Kubernetes EKS ${local.eks_fqdn}"
  homepage          = "https://${local.eks_fqdn}"
  identifier_uris   = ["https://${local.eks_fqdn}"]
  reply_urls        = ["${local.traefik_alb_auth_appreg_reply_urls}"]
  appreg_key_bucket = "${var.terraform_state_s3_bucket}"
  appreg_key_key    = "keys/eks/${var.eks_cluster_name}/appreg_alb_key.json"
}

module "traefik_alb_auth" {
  source               = "../../_sub/compute/eks-alb-auth"
  deploy               = "${var.traefik_alb_auth_deploy}"
  cluster_name         = "${module.eks_heptio.cluster_name}"
  subnet_ids           = "${module.eks_cluster.subnet_ids}"
  vpc_id               = "${module.eks_cluster.vpc_id}"
  autoscaling_group_id = "${module.eks_workers.autoscaling_group_id}"
  alb_certificate_arn  = "${module.traefik_alb_cert.certificate_arn}"
  nodes_sg_id          = "${module.eks_workers.nodes_sg_id}"
  azure_tenant_id      = "${module.traefik_alb_auth_appreg.tenant_id}"
  azure_client_id      = "${module.traefik_alb_auth_appreg.application_id}"
  azure_client_secret  = "${module.traefik_alb_auth_appreg.application_key}"
}

module "traefik_alb_auth_dns" {
  source       = "../../_sub/network/route53-record"
  deploy       = "${var.traefik_alb_auth_deploy}"
  zone_id      = "${local.workload_dns_zone_id}"
  record_name  = ["internal.${var.eks_cluster_name}"]
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = "${module.traefik_alb_auth.alb_fqdn}."
}

module "traefik_alb_auth_dns_core_alias" {
  source       = "../../_sub/network/route53-record"
  deploy       = "${var.traefik_alb_auth_deploy == 1 ? signum(length(var.traefik_alb_auth_core_alias)) : 0}"
  zone_id      = "${local.core_dns_zone_id}"
  record_name  = "${var.traefik_alb_auth_core_alias}"
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = "${element(concat(module.traefik_alb_auth_dns.record_name, list("")), 0)}.${var.workload_dns_zone_name}."

  providers {
    aws = "aws.core"
  }
}

module "traefik_alb_anon" {
  source               = "../../_sub/compute/eks-alb"
  deploy               = "${var.traefik_alb_anon_deploy}"
  cluster_name         = "${module.eks_heptio.cluster_name}"
  subnet_ids           = "${module.eks_cluster.subnet_ids}"
  vpc_id               = "${module.eks_cluster.vpc_id}"
  autoscaling_group_id = "${module.eks_workers.autoscaling_group_id}"
  alb_certificate_arn  = "${module.traefik_alb_cert.certificate_arn}"
  nodes_sg_id          = "${module.eks_workers.nodes_sg_id}"
}

module "traefik_alb_anon_dns" {
  source       = "../../_sub/network/route53-record"
  deploy       = "${var.traefik_alb_anon_deploy}"
  zone_id      = "${local.workload_dns_zone_id}"
  record_name  = ["*.${var.eks_cluster_name}"]
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = "${module.traefik_alb_anon.alb_fqdn}"
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


module "traefik_nlb" {
  source             = "../../_sub/compute/eks-nlb"
  #deploy             = "${var.traefik_nlb_deploy && var.argocd_deploy ? 1 : 0}"
  deploy             = "${var.traefik_nlb_deploy}"
  cluster_name        = "${module.eks_heptio.cluster_name}"
  subnet_ids          = "${module.eks_cluster.subnet_ids}"
  vpc_id              = "${module.eks_cluster.vpc_id}"
  nlb_certificate_arn = "${module.traefik_alb_cert.certificate_arn}"
  nodes_sg_id         = "${module.eks_workers.nodes_sg_id}"
  cidr_blocks         = "${var.traefik_nlb_cidr_blocks}"
  autoscaling_group_id = "${module.eks_workers.autoscaling_group_id}"
}

