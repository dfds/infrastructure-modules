# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend "s3" {}
}

provider "aws" {
  region  = var.aws_region
}

# --------------------------------------------------
# ECR repo and policy
# --------------------------------------------------

module "ecr_repository" {
  source = "../../_sub/compute/ecr-repo"
  names = var.names
  scan_on_push = var.scan_on_push
  pull_principals = var.pull_principals
}

