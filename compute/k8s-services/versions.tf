
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0"
    }

    github = {
      source  = "integrations/github"
      version = ">= 6.0"
    }

    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.0"
    }
  }

}
