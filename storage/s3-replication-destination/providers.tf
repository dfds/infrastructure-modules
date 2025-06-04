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
    role_arn = var.aws_assume_role_arn
  }
}
