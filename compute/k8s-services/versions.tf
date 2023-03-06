
terraform {
  required_version = "~> 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.56.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.18.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.35.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 5.18.0"
    }

    flux = {
      source  = "fluxcd/flux"
      version = "~> 0.24.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.4.0"
    }
  }

}
