terraform {
  required_version = ">= 1.3.0, < 1.6.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.2.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "~> 1.3.0"
    }
  }

}
