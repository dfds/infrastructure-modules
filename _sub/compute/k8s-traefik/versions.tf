terraform {
  required_version = "~> 1.0"

  required_providers {
    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "~> 1.0.0"
    }
  }
}
