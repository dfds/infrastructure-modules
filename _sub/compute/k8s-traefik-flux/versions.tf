terraform {
  required_version = ">= 0.12"

  required_providers {
    github = {
      source  = "integrations/github"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
    }

    htpasswd = {
        source  = "loafoe/htpasswd"
        version = "~> 0.9.0"
      }
  }
}
