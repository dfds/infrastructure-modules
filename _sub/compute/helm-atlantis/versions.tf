terraform {
  required_version = "~> 1.0"

  /*
  Hashicorp-managed providers can be loaded implicitly
  Need to explicitly specific 3rd party Providers
  Version can still be controlled via main module
  */

  required_providers {

    github = {
      source = "integrations/github"
    }

    htpasswd = {
      source  = "loafoe/htpasswd"
      version = "~> 1.0.0"
    }

  }

}
