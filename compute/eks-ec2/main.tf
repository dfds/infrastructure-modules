provider "aws" {

  region = "${var.aws_region}"

  version = "~> 1.40"

  assume_role {
    role_arn = "${var.assume_role_arn}"
  }
}

provider "azuread" {}

terraform {
  backend          "s3"             {}
  required_version = "~> 0.11.7"
}

module "eks_cluster" {
  source       = "../../_sub/compute/eks-cluster"
  cluster_name = "${var.cluster_name}"
}

module "eks_workers" {
  source                       = "../../_sub/compute/eks-workers"
  cluster_name                 = "${var.cluster_name}"
  autoscale_security_group     = "${module.eks_cluster.autoscale_security_group}"
  worker_instance_max_count    = "${var.worker_instance_max_count}"
  worker_instance_min_count    = "${var.worker_instance_min_count}"
  worker_instance_type         = "${var.worker_instance_type}"
  worker_instance_storage_size = "${var.worker_instance_storage_size}"
  vpc_id                       = "${module.eks_cluster.vpc_id}"
  subnet_ids                   = "${module.eks_cluster.subnet_ids}"
  eks_endpoint                 = "${module.eks_cluster.eks_endpoint}"
  eks_certificate_authority    = "${module.eks_cluster.eks_certificate_authority}"
  public_key                   = "${var.public_key}"
  enable_ssh                   = "${var.enable_ssh}"
}

module "eks_heptio" {
  source                    = "../../_sub/compute/eks-heptio"
  cluster_name              = "${var.cluster_name}"
  eks_endpoint              = "${module.eks_cluster.eks_endpoint}"
  eks_certificate_authority = "${module.eks_cluster.eks_certificate_authority}"
  eks_role_arn              = "${module.eks_workers.worker_role}"
  assume_role_arn           = "${var.assume_role_arn}"
}

module "eks_alb" {
  source               = "../../_sub/compute/eks-alb"
  cluster_name         = "${module.eks_heptio.cluster_name}"
  subnet_ids           = "${module.eks_cluster.subnet_ids}"
  vpc_id               = "${module.eks_cluster.vpc_id}"
  autoscaling_group_id = "${module.eks_workers.autoscaling_group_id}"
  alb_certificate_arn  = "${module.eks_certificate.certificate_arn}"
  nodes_sg_id          = "${module.eks_workers.nodes_sg_id}"
}

module "azure_app_registration" {
  source = "../../_sub/security/azure-app-registration"
  name   = "Kubernetes EKS ${var.cluster_name}.${var.dns_zone_name}"
  homepage = "https://${var.cluster_name}.${var.dns_zone_name}"
  identifier_uris = ["https://${var.cluster_name}.${var.dns_zone_name}"]
  reply_urls = ["https://${var.cluster_name}.${var.dns_zone_name}/oauth2/idpresponse"]
}

module "eks_alb_auth" {
  source               = "../../_sub/compute/eks-alb-auth"
  cluster_name         = "${module.eks_heptio.cluster_name}"
  subnet_ids           = "${module.eks_cluster.subnet_ids}"
  vpc_id               = "${module.eks_cluster.vpc_id}"
  autoscaling_group_id = "${module.eks_workers.autoscaling_group_id}"
  alb_certificate_arn  = "${module.eks_certificate.certificate_arn}"
  nodes_sg_id          = "${module.eks_workers.nodes_sg_id}"
  azure_tenant_id            = "${var.azure_tenant_id}"
  azure_client_id            = "${module.azure_app_registration.application_id}"
  azure_client_secret        = "${var.azure_client_secret}"
}

module "eks_certificate" {
  source             = "../../_sub/network/acm-certificate"
  certificate_domain = "*.${var.cluster_name}.${var.dns_zone_name}"
  dns_zone_name      = "${var.dns_zone_name}"
}

module "eks_domain" {
  source       = "../../network/route53-record"
  zone_name    = "${var.dns_zone_name}"
  record_name  = "*.${var.cluster_name}"
  record_type  = "CNAME"
  record_ttl   = "300"
  record_value = "${module.eks_alb.alb_fqdn}"
}

module "eks_auth" {
  source       = "../../network/route53-record"
  zone_name    = "${var.dns_zone_name}"
  record_name  = "internal.${var.cluster_name}"
  record_type  = "CNAME"
  record_ttl   = "300"
  record_value = "${module.eks_alb_auth.alb_fqdn}"
}

module "eks_servicebroker" {
  source              = "../../_sub/compute/eks-servicebroker"
  table_name          = "${var.table_name}"
  aws_region          = "${var.aws_region}"
  workload_account_id = "${var.workload_account_id}"
  worker_role_id      = "${module.eks_workers.worker_role_id}"
  cluster_name        = "${var.cluster_name}"
}
