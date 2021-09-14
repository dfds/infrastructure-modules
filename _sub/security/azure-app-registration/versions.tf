terraform {
  required_version = ">= 0.13"

  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 1.2.2"
    }
  }
}
