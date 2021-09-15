
terraform {
  required_version = ">= 0.12"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.58.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.4.0"
    }

  }

}
