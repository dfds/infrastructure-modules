
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.22.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.38.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1.0"
    }

  }

}
