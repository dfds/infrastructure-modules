
terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.93.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.36.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.2.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.6.0"
    }

    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.0"
    }
  }

}
