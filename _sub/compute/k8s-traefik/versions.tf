terraform {
  required_version = ">= 0.12"

    required_providers {
      htpasswd = {
        source  = "loafoe/htpasswd"
        version = "~> 0.9.0"
      }
  }
}
