terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.79.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.4.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0.0"
    }
  }
}
