terraform {
  required_version = "~> 1.0"

  required_providers {
    github = {
      source = "integrations/github"
    }

    kubectl = {
      source = "gavinbunney/kubectl"
    }

    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "~> 1.0.0"
    }
  }
}
