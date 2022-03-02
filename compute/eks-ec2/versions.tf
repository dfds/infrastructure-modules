
terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.74.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.8.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1.0"
    }

  }

}
