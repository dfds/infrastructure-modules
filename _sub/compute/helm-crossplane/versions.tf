terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.54.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.16.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.8.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }
}
