terraform {
  required_version = ">= 1.8.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.6.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.96.0"
    }
  }
}
