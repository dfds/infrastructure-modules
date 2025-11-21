terraform {
  required_version = ">= 1.6.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.8.0,!=6.8.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.22.0"
    }
  }
}
