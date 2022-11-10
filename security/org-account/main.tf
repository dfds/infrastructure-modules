provider "aws" {
  region  = var.aws_region
  version = "~> 4.38.0"
}

provider "aws" {
  version = "~> 4.38.0"
  region  = var.aws_region

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }

  alias = "workload"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}

module "iam_policies" {
  source = "../../_sub/security/iam-policies"
  # iam_role_trusted_account_root_arn = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
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

resource "aws_iam_role" "cloudadmin" {
  name                 = var.cloudadmin_iam_role_name
  description          = "Cloud-admin role"
  assume_role_policy   = module.iam_idp.adfs_assume_policy
  max_session_duration = 28800

  provider = aws.workload
}

# Policy inline to cloud-admin role
resource "aws_iam_role_policy" "cloudadmin" {
  name   = "CloudAdmin"
  role   = aws_iam_role.cloudadmin.id
  policy = module.iam_policies.admin

  provider = aws.workload
}

resource "aws_iam_role" "auditor" {
  count                = var.name == "dfds-security" ? 1 : 0
  name                 = "Auditor"
  description          = "For reading, querying audit logs"
  assume_role_policy   = module.iam_idp.adfs_assume_policy
  max_session_duration = 28800

  provider = aws.workload
}

# Policy inline to auditor role
resource "aws_iam_role_policy" "auditor" {
  count  = var.name == "dfds-security" ? 1 : 0
  name   = var.auditor_iam_role_name
  role   = aws_iam_role.auditor[0].id
  policy = module.iam_policies.auditor

  provider = aws.workload
}

module "cloudtrail_s3_central" {
  source           = "../../_sub/storage/s3-cloudtrail-bucket"
  create_s3_bucket = var.create_cloudtrail_s3_bucket
  s3_bucket        = var.cloudtrail_central_s3_bucket

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
  s3_bucket  = module.cloudtrail_s3_local.bucket_name
  deploy     = var.cloudtrail_local_s3_bucket != "" ? true : false
  trail_name = "local-audit"

  providers = {
    aws = aws.workload
  }
}
