provider "aws" {
  region = var.aws_region
}

provider "aws" {
  region = var.aws_region
  alias  = "workload"

  assume_role {
    role_arn = "arn:aws:iam::${var.aws_workload_account_id}:role/${var.prime_role_name}"
  }
}

terraform {
  backend "s3" {
  }
}
