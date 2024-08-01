
terraform {
  required_version = ">= 1.3.0, < 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.60.0"
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
