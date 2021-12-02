terraform {
  required_version = "~> 1.0"

  required_providers {

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.11.3"
    }
  }
}
