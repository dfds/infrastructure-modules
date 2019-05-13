provider "aws" {
  version = "~> 1.60.0"
  region  = "${var.aws_region}"

  # Assume role in Master account
  assume_role {
    role_arn = "arn:aws:iam::${var.master_account_id}:role/${var.prime_role_name}"
  }
}

provider "aws" {
  version = "~> 1.60.0"
  region  = "${var.aws_region}"
  alias   = "core"
}

provider "aws" {
  version = "~> 1.60.0"
  region  = "${var.aws_region}"

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = "${var.access_key_master}"
  secret_key = "${var.secret_key_master}"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = "${module.org_account.org_role_arn}"
  }

  alias = "workload"
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend          "s3"             {}
  required_version = "~> 0.11.7"
}

module "iam_policies" {
  source                            = "../../_sub/security/iam-policies"
  iam_role_trusted_account_root_arn = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
}

module "org_account" {
  source        = "../../_sub/security/org-account"
  name          = "${var.name}"
  org_role_name = "${var.org_role_name}"
  email         = "${var.email}"
}

module "iam_account_alias" {
  source        = "../../_sub/security/iam-account-alias"
  account_alias = "${module.org_account.name}"

  providers = {
    aws = "aws.workload"
  }
}

module "iam_idp" {
  source        = "../../_sub/security/iam-idp"
  provider_name = "ADFS"
  adfs_fqdn     = "${var.adfs_fqdn}"

  providers = {
    aws = "aws.workload"
  }
}
