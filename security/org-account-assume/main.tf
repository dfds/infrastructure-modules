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

# resource "null_resource" "apply_tax_settings" {
#   provisioner "local-exec" {
#     command = "python3 /src/taxregistrations.py ${module.org_account.org_role_arn} ${var.tax_settings_document}"
#   }
# }
/*
Does not work, because default provider already assumes a role, and cannot assume from there?
How to solve/align this provider hell between org-account and org-account assume?

* null_resource.apply_tax_settings: Error running command 'python3 /src/taxregistrations.py arn:aws:iam::738063116313:role/OrgRole ./taxsettings.json': exit status 1. Output: Traceback (most recent call last):
  File "/src/taxregistrations.py", line 62, in <module>
    update_tax_registration(sys.argv[1], json_data )
  File "/src/taxregistrations.py", line 26, in update_tax_registration
    role_session_name="AssumeRoleSession")
  File "/usr/lib/python3.6/site-packages/boto/sts/connection.py", line 384, in assume_role
    return self.get_object('AssumeRole', params, AssumedRole, verb='POST')
  File "/usr/lib/python3.6/site-packages/boto/connection.py", line 1208, in get_object
    raise self.ResponseError(response.status, response.reason, body)
boto.exception.BotoServerError: BotoServerError: 403 Forbidden
<ErrorResponse xmlns="https://sts.amazonaws.com/doc/2011-06-15/">
  <Error>
    <Type>Sender</Type>
    <Code>AccessDenied</Code>
    <Message>Access denied</Message>
  </Error>
  <RequestId>6a698849-057e-11e9-9d94-512276d00469</RequestId>
</ErrorResponse>
*/
