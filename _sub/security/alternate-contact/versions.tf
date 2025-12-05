terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.23.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
