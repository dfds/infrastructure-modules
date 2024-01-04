terraform {
  required_version = ">= 1.3.0, < 2.0.0"
  required_providers {

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 5.42.0"
    }
  }
}
