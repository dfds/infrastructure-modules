terraform {
  required_version = ">= 1.3.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.15.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.34.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.41.0"
    }
  }
}
