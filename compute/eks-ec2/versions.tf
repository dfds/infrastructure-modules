
terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.55.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 1.13.0"
    }

  }

}
