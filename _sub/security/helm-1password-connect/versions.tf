terraform {
  required_version = ">= 1.6.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.7.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.16.0"
    }
  }
}
