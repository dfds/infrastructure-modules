terraform {
  required_version = ">= 1.3.0, < 1.6.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.6.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.88.0"
    }
  }
}
