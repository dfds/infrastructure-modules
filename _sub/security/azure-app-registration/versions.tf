terraform {
  required_version = ">= 0.12"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 1.2.2"
    }
  }
}