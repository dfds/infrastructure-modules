terraform {
  required_version = ">= 1.3.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.38.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
  }
}
