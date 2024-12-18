terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.81.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.34.0"
    }
  }
}
