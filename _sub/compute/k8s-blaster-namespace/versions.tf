terraform {
  required_version = ">= 1.3.0, < 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.84.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35.0"
    }
  }
}
