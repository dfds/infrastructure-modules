# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend "s3" {
  }
}

provider "aws" {
  version = "~> 2.43"
  region  = var.aws_region

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

provider "aws" {
  version = "~> 2.43"
  region  = var.aws_region
  alias   = "core"
}

provider "kubernetes" {
  version                = "~> 1.11.1"
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
  load_config_file       = false
}

# provider "azuread" {}

# --------------------------------------------------
# Helm/Tiller
# --------------------------------------------------

resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "tiller-sa"
    namespace = "kube-system"
  }

  automount_service_account_token = true
}

resource "kubernetes_cluster_role_binding" "tiller" {
  metadata {
    name = "tiller-crb"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    api_group = ""
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.tiller.metadata[0].name
    namespace = kubernetes_service_account.tiller.metadata[0].namespace
  }

  depends_on = [kubernetes_service_account.tiller]
}

provider "helm" {
  version         = "~> 0.10.4"
  install_tiller  = true
  namespace       = kubernetes_cluster_role_binding.tiller.subject[0].namespace
  service_account = kubernetes_cluster_role_binding.tiller.subject[0].name

  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}


# --------------------------------------------------
# Traefik
# --------------------------------------------------

module "traefik_deploy" {
  source         = "../../_sub/compute/k8s-traefik"
  deploy         = var.traefik_deploy
  image_version  = var.traefik_version
  priority_class = "service-critical"
  deploy_name    = "traefik"
  cluster_name   = var.eks_cluster_name
  replicas       = length(data.terraform_remote_state.cluster.outputs.eks_worker_subnet_ids)
  http_nodeport  = var.traefik_http_nodeport
  admin_nodeport = var.traefik_admin_nodeport
}

module "traefik_alb_cert" {
  source              = "../../_sub/network/acm-certificate-san"
  deploy              = var.traefik_alb_anon_deploy || var.traefik_alb_auth_deploy || var.traefik_nlb_deploy  || var.traefik_okta_deploy ? true : false
  domain_name         = "*.${local.eks_fqdn}"
  dns_zone_name       = var.workload_dns_zone_name
  core_alias          = concat(var.traefik_alb_auth_core_alias, var.traefik_alb_anon_core_alias, var.traefik_alb_okta_core_alias)
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
  name                  = "${var.eks_cluster_name}-traefik-alb-auth"
  cluster_name          = var.eks_cluster_name
  vpc_id                = data.aws_eks_cluster.eks.vpc_config[0].vpc_id
  subnet_ids            = data.terraform_remote_state.cluster.outputs.eks_worker_subnet_ids
  autoscaling_group_ids = data.terraform_remote_state.cluster.outputs.eks_worker_autoscaling_group_ids
  alb_certificate_arn   = module.traefik_alb_cert.certificate_arn
  nodes_sg_id           = data.terraform_remote_state.cluster.outputs.eks_cluster_nodes_sg_id
  azure_tenant_id       = module.traefik_alb_auth_appreg.tenant_id
  azure_client_id       = module.traefik_alb_auth_appreg.application_id
  azure_client_secret   = module.traefik_alb_auth_appreg.application_key
  target_http_port      = var.traefik_http_nodeport
  target_admin_port     = var.traefik_admin_nodeport
  health_check_path     = var.traefik_health_check_path
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
  name                  = "${var.eks_cluster_name}-traefik-alb"
  cluster_name          = var.eks_cluster_name
  vpc_id                = data.aws_eks_cluster.eks.vpc_config[0].vpc_id
  subnet_ids            = data.terraform_remote_state.cluster.outputs.eks_worker_subnet_ids
  autoscaling_group_ids = data.terraform_remote_state.cluster.outputs.eks_worker_autoscaling_group_ids
  alb_certificate_arn   = module.traefik_alb_cert.certificate_arn
  nodes_sg_id           = data.terraform_remote_state.cluster.outputs.eks_cluster_nodes_sg_id
  target_http_port      = var.traefik_http_nodeport
  target_admin_port     = var.traefik_admin_nodeport
  health_check_path     = var.traefik_health_check_path
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

module "traefik_alb_anon_dns_core_alias" {
  source       = "../../_sub/network/route53-record"
  deploy       = var.traefik_alb_anon_deploy ? length(var.traefik_alb_anon_core_alias) >= 1 : false
  zone_id      = local.core_dns_zone_id
  record_name  = var.traefik_alb_anon_core_alias
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = module.traefik_alb_anon.alb_fqdn

  providers = {
    aws = aws.core
  }
}


# --------------------------------------------------
# Traefik Okta
# --------------------------------------------------

# Traefik 2.x requires a number of Kubernets Custom Resource Definitions:
# https://docs.traefik.io/reference/dynamic-configuration/kubernetes-crd/
# These cannot currently be installed using the native Kubernetes provider.
# However, changes are coming: https://www.hashicorp.com/blog/deploy-any-resource-with-the-new-kubernetes-provider-for-hashicorp-terraform/.
# Alternatively, apply them using kubectl (which depends on kubeconfig file)
# For now - they need to be applied manually.

module "traefik_deploy_okta" {
  source         = "../../_sub/compute/k8s-traefik-v2"
  deploy         = var.traefik_okta_deploy
  image_version  = var.traefik_okta_version
  priority_class = "service-critical"
  deploy_name    = "traefik-okta"
  cluster_name   = var.eks_cluster_name
  replicas       = length(data.terraform_remote_state.cluster.outputs.eks_worker_subnet_ids)
  http_nodeport  = var.traefik_okta_http_nodeport
  admin_nodeport = var.traefik_okta_admin_nodeport
}

module "traefik_alb_okta" {
  source                = "../../_sub/compute/eks-alb"
  deploy                = var.traefik_alb_okta_deploy
  name                  = "${var.eks_cluster_name}-traefik-okta"
  cluster_name          = var.eks_cluster_name
  vpc_id                = data.aws_eks_cluster.eks.vpc_config[0].vpc_id
  subnet_ids            = data.terraform_remote_state.cluster.outputs.eks_worker_subnet_ids
  autoscaling_group_ids = data.terraform_remote_state.cluster.outputs.eks_worker_autoscaling_group_ids
  alb_certificate_arn   = module.traefik_alb_cert.certificate_arn
  nodes_sg_id           = data.terraform_remote_state.cluster.outputs.eks_cluster_nodes_sg_id
  target_http_port      = var.traefik_okta_http_nodeport
  target_admin_port     = var.traefik_okta_admin_nodeport
  health_check_path     = var.traefik_okta_health_check_path
}

module "traefik_alb_okta_dns" {
  source       = "../../_sub/network/route53-record"
  deploy       = var.traefik_alb_okta_deploy
  zone_id      = local.workload_dns_zone_id
  record_name  = ["okta.${var.eks_cluster_name}"]
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = "${module.traefik_alb_okta.alb_fqdn}."
}

module "traefik_alb_okta_dns_core_alias" {
  source       = "../../_sub/network/route53-record"
  deploy       = var.traefik_alb_okta_deploy ? length(var.traefik_alb_okta_core_alias) >= 1 : false
  zone_id      = local.core_dns_zone_id
  record_name  = var.traefik_alb_okta_core_alias
  record_type  = "CNAME"
  record_ttl   = "900"
  record_value = "${element(concat(module.traefik_alb_okta_dns.record_name, [""]), 0)}.${var.workload_dns_zone_name}."

  providers = {
    aws = aws.core
  }
}


# --------------------------------------------------
# KIAM
# --------------------------------------------------

module "kiam_deploy" {
  source                  = "../../_sub/compute/k8s-kiam"
  deploy                  = var.kiam_deploy
  kiam_image_tag          = var.kiam_image_tag
  cluster_name            = var.eks_cluster_name
  priority_class          = "service-critical"
  aws_workload_account_id = var.aws_workload_account_id
  worker_role_id          = data.terraform_remote_state.cluster.outputs.eks_worker_role_id
  agent_deep_liveness     = true
  agent_liveness_timeout  = 5
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

# --------------------------------------------------
# Cloudwatch alarms and alarm notifier (Slack)
# --------------------------------------------------

module "alarm_notifier" {
  source = "../../_sub/monitoring/alarm-notifier/"
  deploy = var.alarm_notifier_deploy
  slack_webhook_url = var.slack_webhook_url
  function_name = var.eks_cluster_name
}

module "cloudwatch_alarm_alb_5XX" {
  source = "../../_sub/monitoring/cloudwatch-alarms/alb-5XX/"
  deploy = var.cloudwatch_alarm_alb_5XX_deploy
  sns_topic_arn = module.alarm_notifier.sns_arn
  alb_arn_suffixes = concat(module.traefik_alb_anon.alb_arn_suffix, module.traefik_alb_auth.alb_arn_suffix)
}

module "cloudwatch_alarm_alb_targets_health" {
  source = "../../_sub/monitoring/cloudwatch-alarms/alb-targets-health"
  deploy = var.cloudwatch_alarm_alb_targets_health_deploy
  sns_topic_arn = module.alarm_notifier.sns_arn
  alb_target_group_arn_suffixes = concat(module.traefik_alb_anon.alb_target_group_arn_suffix, module.traefik_alb_auth.alb_target_group_arn_suffix)
  alb_arn_suffixes = concat(module.traefik_alb_anon.alb_arn_suffix, module.traefik_alb_auth.alb_arn_suffix)
}
