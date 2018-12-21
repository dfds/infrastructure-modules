provider "kubernetes" {
  config_path = "${pathexpand("~/.kube/config_${var.cluster_name}")}"
}

terraform {
  backend          "s3"             {}
  required_version = "~> 0.11.7"
}


module "k8s_traefik" {
  source               = "../../_sub/compute/k8s-traefik"
  traefik_k8s_name     = "${var.traefik_k8s_name}"
}

module "k8s_service_account" {
  source       = "../../_sub/compute/k8s-service-account"
}