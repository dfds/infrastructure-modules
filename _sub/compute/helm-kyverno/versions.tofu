terraform {
  required_version = ">= 1.8.0"

  /*
  Hashicorp-managed providers can be loaded implicitly
  Need to explicitly specific 3rd party Providers
  Version can still be controlled via main module
  */

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "~> 3.0.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.19.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37.0"
    }
  }
}
