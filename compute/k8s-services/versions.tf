
terraform {
  required_version = ">= 1.3.0, < 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.41.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.27.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 6.2.0"
    }

    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.2.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }

}
