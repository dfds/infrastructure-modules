terraform {
  required_version = ">= 0.13"

    required_providers {
      htpasswd = {
        source  = "loafoe/htpasswd"
        version = "~> 0.9.0"
      }
  }
}
