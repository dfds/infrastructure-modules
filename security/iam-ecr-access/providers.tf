provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "workload"

  default_tags {
    tags = var.tags
  }

  assume_role {
    role_arn = "arn:aws:iam::${var.aws_workload_account_id}:role/${var.prime_role_name}"
  }
}

terraform {
  backend "s3" {
  }
}
