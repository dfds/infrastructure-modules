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

# --------------------------------------------------
# AWS Resource Explorer Feature
# --------------------------------------------------

module "aws_resource_explorer_metrics" {
  source = "../../_sub/monitoring/aws-resource-explorer-metrics"

  allowed_assume_arn = "arn:aws:iam::${var.master_account_id}:role/aws-resource-exporter"

  providers = {
    aws = aws.workload
  }
}

resource "aws_resourceexplorer2_index" "aggregator" {
  type = "AGGREGATOR"

  provider = aws.workload
}

resource "aws_resourceexplorer2_view" "aggregator_view" {
  name         = "all-resources"
  default_view = true

  included_property {
    name = "tags"
  }

  depends_on = [aws_resourceexplorer2_index.aggregator]
  provider   = aws.workload
}


resource "aws_resourceexplorer2_index" "us-east-1" {
  type = "LOCAL"

  provider = aws.workload_us-east-1
}

resource "aws_resourceexplorer2_index" "us-east-2" {
  type = "LOCAL"

  provider = aws.workload_us-east-2
}
resource "aws_resourceexplorer2_index" "us-west-1" {
  type = "LOCAL"

  provider = aws.workload_us-west-1
}

resource "aws_resourceexplorer2_index" "us-west-2" {
  type = "LOCAL"

  provider = aws.workload_us-west-2
}

resource "aws_resourceexplorer2_index" "eu-west-1" {
  type = "LOCAL"

  provider = aws.workload_eu-west-1
}

module "iam_github_oidc_provider" {
  count  = var.iam_github_oidc_enabled ? 1 : 0
  source = "../../_sub/security/iam-github-oidc-provider"

  repositories     = var.iam_github_oidc_repositories
  oidc_role_access = var.iam_github_oidc_policy_json
  oidc_role_name   = var.iam_github_oidc_role_name
  oidc_policy_name = var.iam_github_oidc_policy_name

  providers = {
    aws = aws.workload
  }
}

# --------------------------------------------------
# Steampipe
# --------------------------------------------------

module "steampipe-audit" {
  source = "../../_sub/security/steampipe-audit"

  allowed_account_id        = var.security_account_id
  allowed_principal_role_name = var.steampipe_audit_role_name

  providers = {
    aws = aws.workload
  }
}