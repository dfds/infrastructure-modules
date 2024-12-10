
terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.34.0"
    }
  }
}
