terraform {
  required_version = ">= 0.12"

  required_providers {

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.11.3"
    }
  }
}
