
terraform {
  required_version = ">= 1.3.0, < 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.35.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25.0"
    }
  }
}
