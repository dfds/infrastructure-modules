
terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.59.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.31.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }

  }

}
