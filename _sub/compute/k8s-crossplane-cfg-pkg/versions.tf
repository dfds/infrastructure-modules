terraform {
  required_version = ">= 1.3.0, < 1.6.0"

  /*
  Hashicorp-managed providers can be loaded implicitly
  Need to explicitly specific 3rd party Providers
  Version can still be controlled via main module
  */
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.2.0"
    }
  }

}
