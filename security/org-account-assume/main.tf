provider "aws" {
  region = "${var.aws_region}"

  # Assume role in Master account
  assume_role {
    role_arn = "${var.assume_role_arn}"
  }
}

provider "aws" {
  region = "${var.aws_region}"
  alias  = "core"
}

provider "aws" {
  region = "${var.aws_region}"

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account 
  access_key = "${var.access_key_master}"
  secret_key = "${var.secret_key_master}"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.dfds.id}:role/${var.org_role_name}"
    # role_arn = "${module.org_account.org_role_arn}"
    # role_arn = "arn:aws:iam::490910914506:role/OrgRole"
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
  aws_region    = "${var.aws_region}"
}

module "cloudtrail_s3_central" {
  source           = "../../_sub/storage/s3-cloudtrail-bucket"
  create_s3_bucket = "${var.create_cloudtrail_s3_bucket}"
  s3_bucket        = "${var.cloudtrail_central_s3_bucket}"

  providers = {
    aws = "aws.workload"
  }
}

module "cloudtrail_s3_local" {
  source           = "../../_sub/storage/s3-cloudtrail-bucket"
  create_s3_bucket = "${var.cloudtrail_local_s3_bucket != "" ? 1 : 0}"
  s3_bucket        = "${var.cloudtrail_local_s3_bucket}"

  providers = {
    aws = "aws.workload"
  }
}

module "cloudtrail_local" {
  source     = "../../_sub/security/cloudtrail-config"
  s3_bucket  = "${module.cloudtrail_s3_local.bucket_name}"
  trail_name = "local-audit"

  providers = {
    aws = "aws.workload"
  }
}

resource "aws_iam_role" "prime" {
  name               = "${var.prime_role_name}"
  description        = "Admin role to be assumed by Prime"
  assume_role_policy = "${module.iam_policies.trusted_account}"
  provider           = "aws.workload"
}

# Create the a Prime Admin role in the Workload account
resource "aws_iam_role_policy" "prime-admin" {
  name     = "Admin"
  role     = "${aws_iam_role.prime.id}"
  policy   = "${module.iam_policies.admin}"
  provider = "aws.workload"
}

resource "null_resource" "apply_tax_settings" {
  provisioner "local-exec" {
    command = "python3 /src/taxregistrations.py ${module.org_account.org_role_arn} ${var.tax_settings_document}"
  }
}
