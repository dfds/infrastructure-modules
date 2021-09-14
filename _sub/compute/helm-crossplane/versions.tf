terraform {
  required_version = ">= 0.13"

  required_providers {

    kubectl = {
      source  = "gavinbunney/kubectl"
    }
  }
}
