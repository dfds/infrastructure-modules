provider "aws" {
  region = var.aws_region
}

provider "aws" {
  region = var.aws_region

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }

  alias = "workload"
}

provider "aws" {
  region = var.aws_region_2

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }

  alias = "workload_2"
}

provider "datadog" {
  api_key  = var.datadog_api_key
  app_key  = var.datadog_app_key
  api_url  = var.datadog_api_url
  validate = var.datadog_enabled
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

module "datadog" {
  deploy                           = var.datadog_enabled
  source                           = "../../_sub/monitoring/datadog-integration-aws"
  aws_account_id                   = module.org_account.id
  datadog_aws_account_id           = var.datadog_aws_account_id
  filter_tags                      = var.datadog_filter_tags
  host_tags                        = var.datadog_host_tags
  account_specific_namespace_rules = var.datadog_account_specific_namespace_rules
  metrics_collection_enabled       = var.datadog_metrics_collection_enabled
  resource_collection_enabled      = var.datadog_resource_collection_enabled

  providers = {
    aws = aws.workload
  }
}

# --------------------------------------------------
# AWS Resource Explorer Feature
# --------------------------------------------------

resource "aws_resourceexplorer2_index" "aggregator" {
  type = "AGGREGATOR"

  provider = aws.workload
}

resource "aws_resourceexplorer2_index" "eu_west_1" {
  type = "LOCAL"

  provider = aws.workload_2
}

resource "aws_resourceexplorer2_view" "aggregator_view" {
  name = "all-resources"
  default_view = true

  included_property {
    name = "tags"
  }

  depends_on = [aws_resourceexplorer2_index.aggregator]
  provider = aws.workload
}