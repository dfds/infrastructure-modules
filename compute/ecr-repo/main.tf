# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  backend "s3" {}
}

provider "aws" {
  region  = var.aws_region
  version = "~> 2.43"
}

# --------------------------------------------------
# ECR repo and policy
# --------------------------------------------------

module "ecr_repository" {
  source = "../../_sub/compute/ecr-repo"
  name = var.name
  scan_images = var.scan_images
  pull_principals = var.pull_principals
}

