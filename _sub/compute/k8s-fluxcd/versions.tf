terraform {
  required_version = ">= 1.6.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = ">= 6.0,!=6.8.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = ">= 1.0"
    }
  }

}
