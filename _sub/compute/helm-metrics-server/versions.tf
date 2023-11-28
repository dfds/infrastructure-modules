terraform {
  required_version = ">= 1.3.0, < 2.0.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.0"
    }
  }
}
