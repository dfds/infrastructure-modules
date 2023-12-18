provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

terraform {
  backend "s3" {
  }
}
