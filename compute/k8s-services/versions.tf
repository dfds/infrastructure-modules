
terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.74.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.8.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.13.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.4.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.17.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 4.20.0"
    }

    flux = {
      source  = "fluxcd/flux"
      version = "~> 0.10.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }

}
