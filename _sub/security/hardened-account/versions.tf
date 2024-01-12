terraform {
  required_version = ">= 1.3.0, < 2.0.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.32.0"
      configuration_aliases = [aws.workload, aws.workload_2, aws.sso]
    }
  }
}
