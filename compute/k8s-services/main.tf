provider "aws" {

  region = "${var.aws_region}"

  version = "~> 1.40"

  assume_role {
    role_arn = "${var.assume_role_arn}"
  }
}

provider "kubernetes" {
  config_path = "${pathexpand("~/.kube/config_${var.cluster_name}")}"
}

provider "helm" {
  kubernetes {
    config_path = "${pathexpand("~/.kube/config_${var.cluster_name}")}"
  }
}

terraform {
  backend          "s3"             {}
  required_version = "~> 0.11.7"
}

module "k8s_traefik" {
  source               = "../../_sub/compute/k8s-traefik"
  traefik_k8s_name     = "${var.traefik_k8s_name}"
  cluster_name         = "${var.cluster_name}" 
}

module "k8s_service_account" {
  source       = "../../_sub/compute/k8s-service-account"
  cluster_name         = "${var.cluster_name}" 
}

module "k8s_flux" {
  source       = "../../_sub/compute/k8s-flux"
  namespace = "${var.namespace}"
  cluster_name = "${var.cluster_name}"
  config_git_repo_url = "${var.config_git_repo_url}"
  config_git_repo_branch = "${var.config_git_repo_branch}"
  config_git_repo_label = "${var.config_git_repo_label}"
  config_git_private_key = "${base64decode(var.config_git_private_key_base64)}"
  docker_registry_endpoint = "${var.docker_registry_endpoint}"
  docker_registry_username = "${var.docker_registry_username}"
  docker_registry_password = "${var.docker_registry_password}"
  docker_registry_email = "${var.docker_registry_email}"
}

module "k8s_helm" {
  source       = "../../_sub/compute/k8s-helm"
  cluster_name = "${var.cluster_name}"
}

module "k8s_kiam" {
  source       = "../../_sub/compute/k8s-kiam"
  cluster_name = "${var.cluster_name}"
  workload_account_id = "${var.workload_account_id}"
}

module "k8s_servicebroker" {
  source       = "../../_sub/compute/k8s-servicebroker"
  cluster_name = "${var.cluster_name}"
  table_name = "${var.table_name}"
  aws_region = "${var.aws_region}"
  workload_account_id = "${var.workload_account_id}"
}