terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(var.tags, var.data_tags)
  }

  assume_role {
    role_arn = "arn:aws:iam::${var.aws_workload_account_id}:role/${var.prime_role_name}"
  }
}
