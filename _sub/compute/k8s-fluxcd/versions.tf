terraform {
  required_version = "< 1.7.5"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.2.0"
    }
  }

}
