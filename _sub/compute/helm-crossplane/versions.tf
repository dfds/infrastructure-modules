terraform {
  required_version = ">= 0.12"

  required_providers {

    kubectl = {
      source  = "gavinbunney/kubectl"
    }
  }
}
