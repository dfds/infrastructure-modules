
terraform {
  required_version = ">= 1.3.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.59.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.18.0"
    }
  }
}
