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
}

provider "kubernetes" {
  config_path = "${pathexpand("~/.kube/config_${var.eks_cluster_name}")}"
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
