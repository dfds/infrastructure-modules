terraform {
  required_version = "< 1.7.5"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0.0"
    }
  }
}
