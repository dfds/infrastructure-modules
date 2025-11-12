terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.20.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.0"
    }
  }
}
