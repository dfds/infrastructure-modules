
terraform {
  required_version = ">= 1.3.0, < 1.6.0"
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.28.0"
    }
  }
}
