terraform {
  required_version = ">= 1.3.0, < 1.6.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33.0"
    }
  }
}