
terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.40.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.15.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.4.0"
    }

  }

}
