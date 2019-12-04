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

provider "kubernetes" {
  config_path = "${local.kubeconfig_path}"
}

provider "helm" {
  version = "~> 0.8"

  kubernetes {
    config_path = "${local.kubeconfig_path}"
  }
}

# --------------------------------------------------
# Traefik
# --------------------------------------------------

module "traefik_deploy" {
  source          = "../../_sub/compute/k8s-traefik"
  deploy          = "${var.traefik_deploy}"
  kubeconfig_path = "${local.kubeconfig_path}"
  image_version   = "${var.traefik_version}"
  deploy_name     = "${var.traefik_deploy_name}"
  cluster_name    = "${var.eks_cluster_name}"
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
  source       = "../../_sub/compute/eks-alb-auth"
  deploy       = "${var.traefik_alb_auth_deploy}"
  cluster_name = "${var.eks_cluster_name}"
  vpc_id       = "${data.terraform_remote_state.cluster.eks_cluster_vpc_id}"
  subnet_ids   = ["${data.terraform_remote_state.cluster.eks_cluster_subnet_ids}"]
  # subnet_ids           = ["${data.terraform_remote_state.cluster.eks_worker_subnet_ids}"]
  autoscaling_group_ids = ["${data.terraform_remote_state.cluster.eks_worker_autoscaling_group_ids}"]
  alb_certificate_arn  = "${module.traefik_alb_cert.certificate_arn}"
  nodes_sg_id          = "${data.terraform_remote_state.cluster.eks_cluster_nodes_sg_id}"
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
  source       = "../../_sub/compute/eks-alb"
  deploy       = "${var.traefik_alb_anon_deploy}"
  cluster_name = "${var.eks_cluster_name}"
  vpc_id       = "${data.terraform_remote_state.cluster.eks_cluster_vpc_id}"
  subnet_ids   = ["${data.terraform_remote_state.cluster.eks_cluster_subnet_ids}"]
  # subnet_ids           = ["${data.terraform_remote_state.cluster.eks_worker_subnet_ids}"]
  autoscaling_group_ids = ["${data.terraform_remote_state.cluster.eks_worker_autoscaling_group_ids}"]
  alb_certificate_arn  = "${module.traefik_alb_cert.certificate_arn}"
  nodes_sg_id          = "${data.terraform_remote_state.cluster.eks_cluster_nodes_sg_id}"
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

module "traefik_nlb" {
  source = "../../_sub/compute/eks-nlb"

  #deploy             = "${var.traefik_nlb_deploy && var.argocd_deploy ? 1 : 0}"
  deploy       = "${var.traefik_nlb_deploy}"
  cluster_name = "${var.eks_cluster_name}"
  vpc_id       = "${data.terraform_remote_state.cluster.eks_cluster_vpc_id}"
  subnet_ids   = ["${data.terraform_remote_state.cluster.eks_cluster_subnet_ids}"]
  # subnet_ids           = ["${data.terraform_remote_state.cluster.eks_worker_subnet_ids}"]
  nlb_certificate_arn   = "${module.traefik_alb_cert.certificate_arn}"
  nodes_sg_id           = "${data.terraform_remote_state.cluster.eks_cluster_nodes_sg_id}"
  cidr_blocks           = "${var.traefik_nlb_cidr_blocks}"
  autoscaling_group_ids = ["${data.terraform_remote_state.cluster.eks_worker_autoscaling_group_ids}"]
}

# --------------------------------------------------
# KIAM
# --------------------------------------------------

module "kiam_deploy" {
  source                  = "../../_sub/compute/k8s-kiam"
  deploy                  = "${var.kiam_deploy}"
  kubeconfig_path         = "${local.kubeconfig_path}"
  cluster_name            = "${var.eks_cluster_name}"
  aws_workload_account_id = "${var.aws_workload_account_id}"
  worker_role_id          = "${data.terraform_remote_state.cluster.eks_worker_role_id}"
}

# --------------------------------------------------
# Blaster - depends on KIAM
# --------------------------------------------------

module "blaster_namespace" {
  source                   = "../../_sub/compute/k8s-blaster-namespace"
  deploy                   = "${var.blaster_deploy}"
  cluster_name             = "${var.eks_cluster_name}"
  blaster_configmap_bucket = "${data.terraform_remote_state.cluster.blaster_configmap_bucket}"
  kiam_server_role_arn     = "${module.kiam_deploy.server_role_arn}"
}

# --------------------------------------------------
# Service Broker - depends on KIAM
# --------------------------------------------------

module "servicebroker_deploy" {
  source                  = "../../_sub/compute/k8s-servicebroker"
  deploy                  = "${var.servicebroker_deploy}"
  aws_region              = "${var.aws_region}"
  aws_workload_account_id = "${var.aws_workload_account_id}"
  cluster_name            = "${var.eks_cluster_name}"
  table_name              = "eks-servicebroker-${var.eks_cluster_name}"
  deploy_name             = "aws-servicebroker"
  namespace               = "aws-sb"
  chart_repo              = "aws-sb"
  chart_name              = "aws-servicebroker"
  chart_version           = "1.0.0-beta.4"                              # find with 'helm search aws-sb/'
  kiam_server_role_id     = "${module.kiam_deploy.server_role_id}"
}

# --------------------------------------------------
# Flux
# --------------------------------------------------

module "flux_deploy" {
  source            = "../../_sub/compute/k8s-flux"
  deploy            = "${var.flux_deploy}"
  cluster_name      = "${var.eks_cluster_name}"
  namespace         = "${var.flux_k8s_namespace}"
  git_url           = "${var.flux_git_url}"
  git_branch        = "${var.flux_git_branch}"
  git_label         = "${var.flux_git_label}"
  git_key           = "${base64decode(var.flux_git_key_base64)}"
  registry_endpoint = "${var.flux_registry_endpoint}"
  registry_username = "${var.flux_registry_username}"
  registry_password = "${var.flux_registry_password}"
  registry_email    = "${var.flux_registry_email}"
}

# --------------------------------------------------
# ArgoCD
# --------------------------------------------------

# module "argocd_appreg" {
#   source            = "../../_sub/security/azure-app-registration"
#   deploy            = "${var.argocd_deploy}"
#   name              = "ArgoCD ${local.eks_fqdn}"
#   homepage          = "https://argo.${local.eks_fqdn}"
#   identifier_uris   = ["https://argo.${local.eks_fqdn}"]
#   reply_urls        = ["https://argo.${local.eks_fqdn}/auth/callback"]
#   appreg_key_bucket = "${var.terraform_state_s3_bucket}"
#   appreg_key_key    = "keys/eks/${var.eks_cluster_name}/appreg_argocd_key.json"
#   grant_aad_access  = true
# }

# module "argocd_deploy" {
#   source    = "../../_sub/compute/k8s-argocd"
#   deploy    = "${var.argocd_deploy}"
#   namespace = "argocd"

#   oidc_issuer        = "https://sts.windows.net/${module.argocd_appreg.tenant_id}/"
#   oidc_client_id     = "${module.argocd_appreg.application_id}"
#   oidc_client_secret = "${module.argocd_appreg.application_key}"

#   external_url                         = "https://argo.${local.eks_fqdn}"
#   host_url                             = "argo.${local.eks_fqdn}"
#   grpc_host_url                        = "argogrpc.${local.eks_fqdn}"
#   argo_app_image                       = "argoproj/argocd:v0.12.0"
#   cluster_name                         = "${var.eks_cluster_name}"
#   rsa_keypair_key                      = "/eks/argocd/rsa_private"
#   rsa_keypay_parameterstore_aws_region = "eu-central-1"
#   default_repository                   = "${var.argocd_default_repository}"
#   aws_assume_role_arn                  = "${var.aws_assume_role_arn}"
# }

# module "argocd_grpc_dns" {
#   source       = "../../_sub/network/route53-record"
#   deploy       = "${var.argocd_deploy}"
#   zone_id      = "${local.workload_dns_zone_id}"
#   record_name  = ["argogrpc.${var.eks_cluster_name}"]
#   record_type  = "CNAME"
#   record_ttl   = "300"
#   record_value = "${module.traefik_nlb.nlb_fqdn}"
# }

# --------------------------------------------------
# Harbor - depends on KIAM
# --------------------------------------------------

module "harbor_s3" {
  source    = "../../_sub/storage/s3-bucket"
  deploy    = "${var.harbor_deploy}"
  s3_bucket = "harbor-${var.eks_cluster_name}"
}

module "harbor_postgres" {
  source                                 = "../../_sub/database/rds-postgres-harbor"
  deploy                                 = "${var.harbor_deploy}"
  vpc_id                                 = "${data.terraform_remote_state.cluster.eks_cluster_vpc_id}"
  allow_connections_from_security_groups = ["${data.terraform_remote_state.cluster.eks_cluster_nodes_sg_id}"]
  subnet_ids                             = "${data.terraform_remote_state.cluster.eks_cluster_subnet_ids}"

  postgresdb_engine_version = "${var.harbor_postgresdb_engine_version}"
  db_storage_size           = "${var.harbor_db_storage_size}"
  db_instance_size          = "${var.harbor_db_instance_size}"
  ressource_name_prefix     = "harbor-${var.eks_cluster_name}"
  db_name                   = "${var.harbor_postgresdb_default_db_name}"
  db_username               = "${var.harbor_db_server_username}"
  db_password               = "${module.harbor_db_password.random_string}"
}

module "harbor_db_password" {
  source                    = "../../_sub/security/random-string-generate"
  deploy                    = "${var.harbor_deploy}"
  special_character_enabled = false
}

module "harbor_db_password_store" {
  source          = "../../_sub/security/ssm-parameter-store"
  deploy          = "${var.harbor_deploy}"
  key_name        = "/eks/${var.eks_cluster_name}/harbor_db_password"
  key_description = "Default admin passwpord for Harbor database"
  key_value       = "${module.harbor_db_password.random_string}"
}

module "harbor_admin_password" {
  source                    = "../../_sub/security/random-string-generate"
  deploy                    = "${var.harbor_deploy}"
  special_character_enabled = false
}

module "harbor_admin_password_store" {
  source          = "../../_sub/security/ssm-parameter-store"
  deploy          = "${var.harbor_deploy}"
  key_name        = "/eks/${var.eks_cluster_name}/harbor_admin_password"
  key_description = "Default admin passwpord for Harbor portal"
  key_value       = "${module.harbor_admin_password.random_string}"
}

module "harbor_deploy" {
  source                         = "../../_sub/compute/k8s-harbor"
  deploy                         = "${var.harbor_deploy}"
  cluster_name                   = "${var.eks_cluster_name}"
  namespace                      = "${var.harbor_k8s_namespace}"
  registry_endpoint              = "registry.${local.eks_fqdn}"
  registry_endpoint_external_url = "https://registry.${local.eks_fqdn}"
  notary_endpoint                = "notary.${local.eks_fqdn}"
  db_server_host                 = "${module.harbor_postgres.db_address}"
  db_server_username             = "${var.harbor_db_server_username}"
  db_server_password             = "${module.harbor_db_password.random_string}"
  db_server_port                 = "${module.harbor_postgres.db_port}"
  bucket_name                    = "${module.harbor_s3.bucket_name}"
  s3_region                      = "${var.aws_region}"
  s3_region_endpoint             = "http://s3.${var.aws_region}.amazonaws.com"
  db_server_default_db_name      = "${var.harbor_postgresdb_default_db_name}"
  portal_admin_password          = "${module.harbor_admin_password.random_string}"
  aws_workload_account_id        = "${var.aws_workload_account_id}"
  kiam_server_role_id            = "${module.kiam_deploy.server_role_id}"
}
