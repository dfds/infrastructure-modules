terraform {
  required_version = ">= 1.3.0, < 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.78.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.34.0"
    }
  }
}
