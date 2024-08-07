
terraform {
  required_version = ">= 1.8.0"

  /*
  Hashicorp-managed providers can be loaded implicitly
  Need to explicitly specific 3rd party Providers
  Version can still be controlled via main module
  */

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.61.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.2.0"
    }
  }

}
