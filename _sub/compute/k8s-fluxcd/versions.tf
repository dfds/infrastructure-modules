terraform {
  required_version = ">= 1.3.0, < 2.0.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.26.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "~> 0.25.0"
    }
  }

}
