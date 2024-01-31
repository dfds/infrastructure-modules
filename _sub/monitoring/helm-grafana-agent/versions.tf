terraform {
  required_version = "< 1.7.3"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.0"
    }
  }
}
