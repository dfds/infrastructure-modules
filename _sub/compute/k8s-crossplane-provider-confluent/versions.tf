terraform {
  required_version = "~> 1.0"
    required_providers {

    kubernetes = {
      source  = "hashicorp/kubernetes"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
    }
  }
}