terraform {
  required_version = ">= 0.13"

  required_providers {
    github = {
      source  = "integrations/github"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
    }
  }
}
