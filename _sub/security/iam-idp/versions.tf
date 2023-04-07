
terraform {
  required_version = ">= 1.3.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.61.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.2.0"
    }
  }
}
