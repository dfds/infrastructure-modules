provider "aws" {
  region = "${var.aws_region}"

  version = "~> 1.40"

  assume_role {
    role_arn = "${var.assume_role_arn}"
  }
}

provider "azuread" {}

# Kubernetes provider needed by Harbor
# provider "kubernetes" {
#   config_path = "${pathexpand("~/.kube/config_${var.cluster_name}")}"
# }

# Helm provider used by Harbor
# provider "helm" {
#   kubernetes {
#     config_path = "${pathexpand("~/.kube/config_${var.cluster_name}")}"
#   }
# }

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

module "apply_blaster_configmap" {
  source          = "../../_sub/compute/k8s-blaster-configmap"
  cluster_name    = "${module.eks_heptio.cluster_name}"
  s3_bucket       = "${var.blaster_configmap_bucket}"
  assume_role_arn = "${var.assume_role_arn}"
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
  source            = "../../_sub/security/azure-app-registration"
  name              = "Kubernetes EKS ${var.cluster_name}.${var.dns_zone_name}"
  homepage          = "https://${var.cluster_name}.${var.dns_zone_name}"
  identifier_uris   = ["https://${var.cluster_name}.${var.dns_zone_name}"]
  reply_urls        = ["https://internal.${var.cluster_name}.${var.dns_zone_name}/oauth2/idpresponse"]
  appreg_key_bucket = "${var.terraform_state_s3_bucket}"
  appreg_key_key    = "keys/eks/${var.cluster_name}/appreg_key.json"
}

module "eks_alb_auth" {
  source               = "../../_sub/compute/eks-alb-auth"
  cluster_name         = "${module.eks_heptio.cluster_name}"
  subnet_ids           = "${module.eks_cluster.subnet_ids}"
  vpc_id               = "${module.eks_cluster.vpc_id}"
  autoscaling_group_id = "${module.eks_workers.autoscaling_group_id}"
  alb_certificate_arn  = "${module.eks_certificate.certificate_arn}"
  nodes_sg_id          = "${module.eks_workers.nodes_sg_id}"
  azure_tenant_id      = "${module.azure_app_registration.tenant_id}"
  azure_client_id      = "${module.azure_app_registration.application_id}"
  azure_client_secret  = "${module.azure_app_registration.application_key}"
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

module "eks_kiam" {
  source              = "../../_sub/compute/eks-kiam"
  cluster_name        = "${var.cluster_name}"
  workload_account_id = "${var.workload_account_id}"
  worker_role_id      = "${module.eks_workers.worker_role_id}"
}

module "eks_servicebroker" {
  source              = "../../_sub/compute/eks-servicebroker"
  table_name          = "${var.table_name}"
  aws_region          = "${var.aws_region}"
  workload_account_id = "${var.workload_account_id}"
  kiam_server_role_id = "${module.eks_kiam.kiam_server_role_id}"
  cluster_name        = "${var.cluster_name}"
}

# module "s3_harbor" {
#   source    = "../../_sub/storage/s3-bucket"
#   s3_bucket = "${var.harbor_s3_bucket}"
# }

# module "rds_postgres_harbor" {
#   source                                 = "../../_sub/database/rds-postgres-harbor"
#   vpc_id                                 = "${module.eks_cluster.vpc_id}"
#   allow_connections_from_security_groups = ["${module.eks_workers.nodes_sg_id}"]
#   subnet_ids                             = "${module.eks_cluster.subnet_ids}"

#   postgresdb_engine_version = "${var.harbor_postgresdb_engine_version}"
#   db_storage_size           = "${var.harbor_db_storage_size}"
#   db_instance_size          = "${var.harbor_db_instance_size}"
#   db_server_identifier      = "${var.harbor_db_server_identifier}"
#   db_name                   = "postgres"
#   db_username               = "${var.harbor_db_server_username}"
#   db_password               = "${var.harbor_db_server_password}"
#   port                      = "${var.harbor_db_server_port}"

#   harbor_k8s_namespace = "${var.harbor_k8s_namespace}"
# }

# module "k8s_harbor" {
#   source = "../../_sub/compute/k8s-harbor"

#   bucket_name                    = "${module.s3_harbor.bucket_name}"
#   worker_role_id                 = "${module.eks_workers.worker_role_id}"
#   cluster_name                   = "${var.cluster_name}"
#   namespace                      = "${var.k8s_registry_namespace}"
#   registry_endpoint              = "registry.${var.cluster_name}.${var.dns_zone_name}"
#   registry_endpoint_external_url = "https://registry.${var.cluster_name}.${var.dns_zone_name}"
#   notary_endpoint                = "notary.${var.cluster_name}.${var.dns_zone_name}"
#   s3_region                      = "${var.aws_region}"
#   s3_region_endpoint             = "http://s3.${var.aws_region}.amazonaws.com"
#   db_server_host                 = "${module.rds_postgres_harbor.harbor_db_address}"
#   db_server_username             = "${var.harbor_db_server_username}"
#   db_server_password             = "${var.harbor_db_server_password}"
#   db_server_port                 = "${var.harbor_db_server_port}"

#   s3_acces_key  = "${var.harbor_s3_acces_key}"
#   s3_secret_key = "${var.harbor_s3_secret_key}"
# }
