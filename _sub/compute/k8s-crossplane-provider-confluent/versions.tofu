terraform {
  required_version = ">= 1.8.0"
  required_providers {

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.32.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.2.0"
    }
  }
}
