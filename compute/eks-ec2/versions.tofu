
terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.37.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.1.0"
    }

  }

}
