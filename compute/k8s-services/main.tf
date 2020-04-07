# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend "s3" {
  }
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.43"

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.43"
  alias   = "core"
}

provider "kubernetes" {
  config_path = local.kubeconfig_path
}

provider "helm" {
  version = "~> 0.8"

  kubernetes {
    config_path = local.kubeconfig_path
  }
}

# --------------------------------------------------
# Traefik
# --------------------------------------------------

module "traefik_deploy" {
  source          = "../../_sub/compute/k8s-traefik"
  deploy          = var.traefik_deploy
  kubeconfig_path = local.kubeconfig_path
  image_version   = var.traefik_version
  deploy_name     = var.traefik_deploy_name
  cluster_name    = var.eks_cluster_name
}

module "traefik_alb_cert" {
  source              = "../../_sub/network/acm-certificate-san"
  deploy              = var.traefik_alb_anon_deploy || var.traefik_alb_auth_deploy || var.traefik_nlb_deploy ? true : false
  domain_name         = "*.${local.eks_fqdn}"
  dns_zone_name       = var.workload_dns_zone_name
  core_alias          = var.traefik_alb_auth_core_alias
  aws_region          = var.aws_region          # Workaround to https://github.com/hashicorp/terraform/issues/21416
  aws_assume_role_arn = var.aws_assume_role_arn # Workaround to https://github.com/hashicorp/terraform/issues/21416
}

module "traefik_alb_auth_appreg" {
  source            = "../../_sub/security/azure-app-registration"
  deploy            = var.traefik_alb_auth_deploy
  name              = "Kubernetes EKS ${local.eks_fqdn}"
  homepage          = "https://${local.eks_fqdn}"
  identifier_uris   = ["https://${local.eks_fqdn}"]
  reply_urls        = local.traefik_alb_auth_appreg_reply_urls
  appreg_key_bucket = var.terraform_state_s3_bucket
  appreg_key_key    = "keys/eks/${var.eks_cluster_name}/appreg_alb_key.json"
}

module "traefik_alb_auth" {
  source                = "../../_sub/compute/eks-alb-auth"
  deploy                = var.traefik_alb_auth_deploy
  cluster_name          = var.eks_cluster_name
  vpc_id                = data.terraform_remote_state.cluster.outputs.eks_cluster_vpc_id
  subnet_ids            = data.terraform_remote_state.cluster.outputs.eks_worker_subnet_ids
  autoscaling_group_ids = data.terraform_remote_state.cluster.outputs.eks_worker_autoscaling_group_ids
  alb_certificate_arn   = module.traefik_alb_cert.certificate_arn
  nodes_sg_id           = data.terraform_remote_state.cluster.outputs.eks_cluster_nodes_sg_id
  azure_tenant_id       = module.traefik_alb_auth_appreg.tenant_id
  azure_client_id       = module.traefik_alb_auth_appreg.application_id
  azure_client_secret   = module.traefik_alb_auth_appreg.application_key
}

module "traefik_alb_auth_dns" {
  source       = "../../_sub/network/route53-record"
  deploy       = var.traefik_alb_auth_deploy
  zone_id      = local.workload_dns_zone_id
  record_name  = ["internal.${var.eks_cluster_name}"]
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = "${module.traefik_alb_auth.alb_fqdn}."
}

module "traefik_alb_auth_dns_core_alias" {
  source       = "../../_sub/network/route53-record"
  deploy       = var.traefik_alb_auth_deploy ? length(var.traefik_alb_auth_core_alias) >= 1 : false
  zone_id      = local.core_dns_zone_id
  record_name  = var.traefik_alb_auth_core_alias
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = "${element(concat(module.traefik_alb_auth_dns.record_name, [""]), 0)}.${var.workload_dns_zone_name}."

  providers = {
    aws = aws.core
  }
}

module "traefik_alb_anon" {
  source                = "../../_sub/compute/eks-alb"
  deploy                = var.traefik_alb_anon_deploy
  cluster_name          = var.eks_cluster_name
  vpc_id                = data.terraform_remote_state.cluster.outputs.eks_cluster_vpc_id
  subnet_ids            = data.terraform_remote_state.cluster.outputs.eks_worker_subnet_ids
  autoscaling_group_ids = data.terraform_remote_state.cluster.outputs.eks_worker_autoscaling_group_ids
  alb_certificate_arn   = module.traefik_alb_cert.certificate_arn
  nodes_sg_id           = data.terraform_remote_state.cluster.outputs.eks_cluster_nodes_sg_id
}

module "traefik_alb_anon_dns" {
  source       = "../../_sub/network/route53-record"
  deploy       = var.traefik_alb_anon_deploy
  zone_id      = local.workload_dns_zone_id
  record_name  = ["*.${var.eks_cluster_name}"]
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = module.traefik_alb_anon.alb_fqdn
}

# --------------------------------------------------
# Cloudwatch ALB 500 errors alerts to slack
# --------------------------------------------------

module "traefik_cw_lb500_alerts" {
  source           = "../../_sub/monitoring/cw_lb500_alerts"
  deploy           = var.cwalarms_alb_500_deploy
  alb_arn_suffixes = concat(module.traefik_alb_anon.alb_arn_suffix, module.traefik_alb_auth.alb_arn_suffix)
  slack_hook       = var.cwalarms_alb_500_slack_hook              # A slack webhook that can accept messages
  slack_channel    = var.cwalarms_alb_500_slack_channel           # The channel to post messages to
  function_name    = "cw_to_slack_eks_${var.eks_cluster_name}"    # Unique name for Lambda since terraform is missing a name prefix
  sns_name         = "eks_alb_500_errors_${var.eks_cluster_name}" # Tried to lambda function so also need a unique name
}

# --------------------------------------------------
# KIAM
# --------------------------------------------------

module "kiam_deploy" {
  source                  = "../../_sub/compute/k8s-kiam"
  deploy                  = var.kiam_deploy
  kubeconfig_path         = local.kubeconfig_path
  cluster_name            = var.eks_cluster_name
  aws_workload_account_id = var.aws_workload_account_id
  worker_role_id          = data.terraform_remote_state.cluster.outputs.eks_worker_role_id
}

# --------------------------------------------------
# Blaster - depends on KIAM
# --------------------------------------------------

module "blaster_namespace" {
  source                   = "../../_sub/compute/k8s-blaster-namespace"
  deploy                   = var.blaster_deploy
  cluster_name             = var.eks_cluster_name
  blaster_configmap_bucket = data.terraform_remote_state.cluster.outputs.blaster_configmap_bucket
  kiam_server_role_arn     = module.kiam_deploy.server_role_arn
  extra_permitted_roles    = var.blaster_namespace_extra_permitted_roles
}