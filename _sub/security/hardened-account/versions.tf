terraform {
  required_version = "< 1.7.5"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 5.38.0"
      configuration_aliases = [aws.workload, aws.workload_2, aws.sso]
    }
  }
}
