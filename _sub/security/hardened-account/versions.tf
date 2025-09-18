terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 6.14.0"
      configuration_aliases = [aws.workload, aws.workload_2, aws.sso]
    }
  }
}
