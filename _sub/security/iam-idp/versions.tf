
terraform {
  required_version = "~> 1.3.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.58.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.2.0"
    }
  }
}
