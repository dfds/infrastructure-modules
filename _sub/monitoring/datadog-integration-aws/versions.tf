terraform {
  required_version = ">= 1.3.0, < 2.0.0"

  required_providers {
    datadog = {
      source  = "DataDog/datadog"
      version = "3.25.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.4.0"
    }
  }
}
