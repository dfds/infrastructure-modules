terraform {
  required_version = ">= 1.3.0, < 2.0.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.44.0"
    }
  }
}
