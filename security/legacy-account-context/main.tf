# --------------------------------------------------
# Init
# --------------------------------------------------

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}

provider "aws" {
  region = var.aws_region

  # Assume role in Master account
  assume_role {
    role_arn = "arn:aws:iam::${var.master_account_id}:role/${var.prime_role_name}"
  }
}

# Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
provider "aws" {
  region     = var.aws_region
  alias      = "workload"
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = "arn:aws:iam::${var.account_id}:role/${var.org_role_name}"
  }
}


# --------------------------------------------------
# Resource Explorer providers in all enabled regions
# --------------------------------------------------

# EU
provider "aws" {
  region     = "eu-west-1"
  alias      = "workload_eu-west-1"
  access_key = var.access_key_master
  secret_key = var.secret_key_master
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region     = "eu-west-2"
  alias      = "workload_eu-west-2"
  access_key = var.access_key_master
  secret_key = var.secret_key_master
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region     = "eu-west-3"
  alias      = "workload_eu-west-3"
  access_key = var.access_key_master
  secret_key = var.secret_key_master
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region     = "eu-north-1"
  alias      = "workload_eu-north-1"
  access_key = var.access_key_master
  secret_key = var.secret_key_master
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

# USA
provider "aws" {
  region     = "us-east-1"
  alias      = "workload_us-east-1"
  access_key = var.access_key_master
  secret_key = var.secret_key_master
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region     = "us-east-2"
  alias      = "workload_us-east-2"
  access_key = var.access_key_master
  secret_key = var.secret_key_master
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region     = "us-west-1"
  alias      = "workload_us-west-1"
  access_key = var.access_key_master
  secret_key = var.secret_key_master
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region     = "us-west-2"
  alias      = "workload_us-west-2"
  access_key = var.access_key_master
  secret_key = var.secret_key_master
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}
# Asia Pacific
provider "aws" {
  region     = "ap-south-1"
  alias      = "workload_ap-south-1"
  access_key = var.access_key_master
  secret_key = var.secret_key_master
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region     = "ap-northeast-3"
  alias      = "workload_ap-northeast-3"
  access_key = var.access_key_master
  secret_key = var.secret_key_master
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region     = "ap-northeast-2"
  alias      = "workload_ap-northeast-2"
  access_key = var.access_key_master
  secret_key = var.secret_key_master
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}


provider "aws" {
  region     = "ap-southeast-1"
  alias      = "workload_ap-southeast-1"
  access_key = var.access_key_master
  secret_key = var.secret_key_master
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region     = "ap-southeast-2"
  alias      = "workload_ap-southeast-2"
  access_key = var.access_key_master
  secret_key = var.secret_key_master
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region     = "ap-northeast-1"
  alias      = "workload_ap-northeast-1"
  access_key = var.access_key_master
  secret_key = var.secret_key_master
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

# Canada
provider "aws" {
  region     = "ca-central-1"
  alias      = "workload_ca-central-1"
  access_key = var.access_key_master
  secret_key = var.secret_key_master
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

# South America
provider "aws" {
  region     = "sa-east-1"
  alias      = "workload_sa-east-1"
  access_key = var.access_key_master
  secret_key = var.secret_key_master
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

# --------------------------------------------------
# Create account
# --------------------------------------------------

module "org_account" {
  source        = "../../_sub/security/org-account"
  name          = var.name
  org_role_name = var.org_role_name
  email         = var.email
  parent_id     = var.parent_id
  sleep_after   = 120
}

module "iam_account_alias" {
  source        = "../../_sub/security/iam-account-alias"
  account_alias = module.org_account.name

  providers = {
    aws = aws.workload
  }
}

# --------------------------------------------------
# Certero
# --------------------------------------------------

module "iam_policies" {
  source                            = "../../_sub/security/iam-policies"
  iam_role_trusted_account_root_arn = ["arn:aws:iam::${var.core_account_id}:root"] # Account ID from variable instead of data.aws_caller_identity - seems to get rate-throttled
}

module "iam_role_certero" {
  source               = "../../_sub/security/iam-role"
  role_name            = "CerteroRole"
  role_description     = "Used by CerteroRole to make inventory of AWS resources"
  max_session_duration = 3600
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy_master_account.json
  role_policy_name     = "CerteroEndpoint"
  role_policy_document = module.iam_policies.certero_endpoint

  providers = {
    aws = aws.workload
  }
}

# --------------------------------------------------
# AWS Resource Explorer
# --------------------------------------------------

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
  type     = "LOCAL"
  provider = aws.workload_us-east-1
}

resource "aws_resourceexplorer2_index" "us-east-2" {
  type     = "LOCAL"
  provider = aws.workload_us-east-2
}

resource "aws_resourceexplorer2_index" "us-west-1" {
  type     = "LOCAL"
  provider = aws.workload_us-west-1
}

resource "aws_resourceexplorer2_index" "us-west-2" {
  type     = "LOCAL"
  provider = aws.workload_us-west-2
}

resource "aws_resourceexplorer2_index" "ap-south-1" {
  type     = "LOCAL"
  provider = aws.workload_ap-south-1
}

resource "aws_resourceexplorer2_index" "ap-northeast-3" {
  type     = "LOCAL"
  provider = aws.workload_ap-northeast-3
}

resource "aws_resourceexplorer2_index" "ap-northeast-2" {
  type     = "LOCAL"
  provider = aws.workload_ap-northeast-2
}

resource "aws_resourceexplorer2_index" "ap-southeast-1" {
  type     = "LOCAL"
  provider = aws.workload_ap-southeast-1
}

resource "aws_resourceexplorer2_index" "ap-southeast-2" {
  type     = "LOCAL"
  provider = aws.workload_ap-southeast-2
}

resource "aws_resourceexplorer2_index" "ap-northeast-1" {
  type     = "LOCAL"
  provider = aws.workload_ap-northeast-1
}

resource "aws_resourceexplorer2_index" "ca-central-1" {
  type     = "LOCAL"
  provider = aws.workload_ca-central-1
}

resource "aws_resourceexplorer2_index" "eu-west-1" {
  type     = "LOCAL"
  provider = aws.workload_eu-west-1
}

resource "aws_resourceexplorer2_index" "eu-west-2" {
  type     = "LOCAL"
  provider = aws.workload_eu-west-2
}

resource "aws_resourceexplorer2_index" "eu-west-3" {
  type     = "LOCAL"
  provider = aws.workload_eu-west-3
}

resource "aws_resourceexplorer2_index" "eu-north-1" {
  type     = "LOCAL"
  provider = aws.workload_eu-north-1
}

resource "aws_resourceexplorer2_index" "sa-east-1" {
  type     = "LOCAL"
  provider = aws.workload_sa-east-1
}
