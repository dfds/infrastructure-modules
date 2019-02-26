# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend          "s3"             {}
  required_version = "~> 0.11.7"
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.40"

  assume_role {
    role_arn = "${var.aws_assume_role_arn}"
  }
}

provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.40"
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

module "apply_blaster_configmap" {
  source              = "../../_sub/compute/k8s-blaster-configmap"
  deploy              = "${var.blaster_configmap_deploy}"
  aws_assume_role_arn = "${var.aws_assume_role_arn}"
  cluster_name        = "${module.eks_heptio.cluster_name}"
  s3_bucket           = "${var.blaster_configmap_bucket}"
}

# --------------------------------------------------
# Tiller (Helm server)
# --------------------------------------------------

module "k8s_helm" {
  source       = "../../_sub/compute/k8s-helm"
  cluster_name = "${var.eks_cluster_name}"
}

# --------------------------------------------------
# Deployment service account
# --------------------------------------------------

module "k8s_service_account" {
  source       = "../../_sub/compute/k8s-service-account"
  cluster_name = "${var.eks_cluster_name}"
}

module "k8s_service_account_store_secret" {
  source          = "../../_sub/security/ssm-parameter-store"
  key_name        = "/eks/${var.eks_cluster_name}/deploy_user"
  key_description = "Kube config file for general deployment user"
  key_value       = "${module.k8s_service_account.deploy_user_config}"
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
  cluster_name = "${var.eks_cluster_name}"
}

module "traefik_alb_cert" {
  source         = "../../_sub/network/acm-certificate-san"
  deploy         = "${var.traefik_alb_anon_deploy || var.traefik_alb_auth_deploy ? 1 : 0}"
  domain_name    = "*.${var.eks_cluster_name}.${var.traefik_dns_zone_name}"
  dns_zone_name  = "${var.traefik_dns_zone_name}"
  core_alt_names = "${var.traefik_alb_cert_core_alt_names}"
}

module "traefik_alb_auth_appreg" {
  source            = "../../_sub/security/azure-app-registration"
  deploy            = "${var.traefik_alb_auth_deploy}"
  name              = "Kubernetes EKS ${var.eks_cluster_name}.${var.traefik_dns_zone_name}"
  homepage          = "https://${var.eks_cluster_name}.${var.traefik_dns_zone_name}"
  identifier_uris   = ["https://${var.eks_cluster_name}.${var.traefik_dns_zone_name}"]
  reply_urls        = ["https://internal.${var.eks_cluster_name}.${var.traefik_dns_zone_name}/oauth2/idpresponse"]
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
  zone_name    = "${var.traefik_dns_zone_name}"
  record_name  = "internal.${var.eks_cluster_name}"
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = "${module.traefik_alb_auth.alb_fqdn}"
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
  zone_name    = "${var.traefik_dns_zone_name}"
  record_name  = "*.${var.eks_cluster_name}"
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

# module "traefik_nlb" {
# Currently used only with Argo CD
# source             = "../../_sub/network/acm-certificate"
# deploy             = "${var.traefik_nlb_deploy && var.argocd_deploy ? 1 : 0}"
# ...
# }

