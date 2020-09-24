provider "aws" {
  version = "~> 2.43.0"
  region  = var.aws_region

  # Assume role in Master account
  assume_role {
    role_arn = "arn:aws:iam::${var.master_account_id}:role/${var.prime_role_name}"
  }
}

provider "aws" {
  version = "~> 2.43.0"
  region  = var.aws_region
  alias   = "core"
}

provider "aws" {
  version = "~> 2.43.0"
  region  = var.aws_region

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }

  alias = "workload"
}

terraform {
  backend "s3" {
  }
}

module "iam_policies" {
  source                            = "../../_sub/security/iam-policies"
  iam_role_trusted_account_root_arn = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
}

module "org_account" {
  source        = "../../_sub/security/org-account"
  name          = var.name
  org_role_name = var.org_role_name
  email         = var.email
}

module "iam_account_alias" {
  source        = "../../_sub/security/iam-account-alias"
  account_alias = module.org_account.name

  providers = {
    aws = aws.workload
  }
}

module "iam_idp" {
  source        = "../../_sub/security/iam-idp"
  provider_name = "ADFS"
  adfs_fqdn     = var.adfs_fqdn

  providers = {
    aws = aws.workload
  }
}

module "cloudtrail_s3_local" {
  source           = "../../_sub/storage/s3-cloudtrail-bucket"
  create_s3_bucket = var.cloudtrail_local_s3_bucket != "" ? true : false
  s3_bucket        = var.cloudtrail_local_s3_bucket

  providers = {
    aws = aws.workload
  }
}

module "cloudtrail_local" {
  source     = "../../_sub/security/cloudtrail-config"
  deploy     = var.cloudtrail_local_s3_bucket != "" ? true : false
  s3_bucket  = module.cloudtrail_s3_local.bucket_name
  trail_name = "local-audit"

  providers = {
    aws = aws.workload
  }
}

resource "aws_iam_role" "prime" {
  name               = var.prime_role_name
  description        = "Admin role to be assumed by Prime"
  assume_role_policy = module.iam_policies.trusted_account
  provider           = aws.workload
}

# Create the a Prime Admin role in the Workload account
resource "aws_iam_role_policy" "prime-admin" {
  name     = "Admin"
  role     = aws_iam_role.prime.id
  policy   = module.iam_policies.admin
  provider = aws.workload
}

# Create cloud-engineer role for the workload account
resource "aws_iam_role" "cloudengineer_role" {
  name               = var.cloudengineer_iam_role_name
  description        = "Cloud-engineer role"
  assume_role_policy = module.iam_idp.adfs_assume_policy
  max_session_duration = 28800

  provider = aws.workload
}

# Attach policy to cloud-engineer role
resource "aws_iam_role_policy" "cloudengineer_role_policy" {
  name   = "CloudEngineer"
  role   = aws_iam_role.cloudengineer_role.id
  policy = module.iam_policies.cloudengineer

  provider = aws.workload
}

# Create cloud-admin role for the workload account
resource "aws_iam_role" "cloudadmin_role" {
  name               = var.cloudadmin_iam_role_name
  description        = "Cloud-admin role"
  assume_role_policy = module.iam_idp.adfs_assume_policy
  max_session_duration = 28800

  provider = aws.workload
}

# Attach policy to cloud-admin role
resource "aws_iam_role_policy" "cloudadmin_role_policy" {
  name   = "CloudAdmin"
  role   = aws_iam_role.cloudadmin_role.id
  policy = module.iam_policies.admin

  provider = aws.workload
}