terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.23.0"
    }
    github = {
      source  = "integrations/github"
      version = ">= 6.8.0,!=6.8.2"
    }
  }
}
