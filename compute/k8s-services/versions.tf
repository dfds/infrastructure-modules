
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.23.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.19.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0"
    }

    github = {
      source  = "integrations/github"
      version = ">= 6.0,!=6.8.2"
    }

    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.7.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 3.7.0"
    }
  }

}
