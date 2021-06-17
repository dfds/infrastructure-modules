
terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.45"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.3.2"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.9.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.2.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1.5.1"
    }

    github = {
      source  = "integrations/github"
      version = ">= 4.1.0"
    }

    flux = {
      source  = "fluxcd/flux"
      version = ">= 0.0.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.0.0"
    }
  }

}
