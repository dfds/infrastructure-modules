
terraform {
  required_version = ">= 1.3.0, < 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2.1"
    }
  }
}
