terraform {
  required_version = ">= 0.12"

  /*
  Hashicorp-managed providers can be loaded implicitly
  Need to explicitly specific 3rd party Providers
  Version can still be controlled via main module
  */

  required_providers {

    github = {
      source = "integrations/github"
    }

  }

}
