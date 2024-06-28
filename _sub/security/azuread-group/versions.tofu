terraform {
  required_version = ">= 1.8.0"
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.53.0"
    }
  }
}
