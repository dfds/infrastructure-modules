terraform {
  required_version = ">= 1.3.0, < 2.0.0"

  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "3.28.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.10.0"
    }
  }
}
