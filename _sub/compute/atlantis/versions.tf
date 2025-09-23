terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0, != 6.14.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.6.0"
    }
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "~> 1.4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.0"
    }
  }
}
