
terraform {
  required_version = ">= 1.3.0, < 1.6.0"
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}
