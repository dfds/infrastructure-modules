
terraform {
  required_version = ">= 0.13"

  /*
  Hashicorp-managed providers can be loaded implicitly
  Need to explicitly specific 3rd party Providers
  Version can still be controlled via main module
  */

  required_providers {

    kubectl = {
      source  = "gavinbunney/kubectl"
    }

    github = {
      source  = "integrations/github"
    }

    flux = {
      source  = "fluxcd/flux"
    }

  }

}
