
terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.75.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.9.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1.0"
    }

  }

}
