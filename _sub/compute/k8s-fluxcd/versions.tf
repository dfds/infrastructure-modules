
terraform {
  required_version = ">= 1.3.0, < 2.0.0"

  /*
  Hashicorp-managed providers can be loaded implicitly
  Need to explicitly specific 3rd party Providers
  Version can still be controlled via main module
  */

  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.19.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "~> 0.25.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.19.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.0"
    }
  }

}
