provider "aws" {
  region = var.aws_region

  # Assume role in Master account
  assume_role {
    role_arn     = "arn:aws:iam::${var.master_account_id}:role/${var.prime_role_name}"
    session_name = var.aws_session_name
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "core"
}

provider "aws" {
  region = var.aws_region

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn     = module.org_account.org_role_arn
    session_name = var.aws_session_name
  }

  alias = "workload"
}

provider "aws" {
  region = var.aws_region_2

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn     = module.org_account.org_role_arn
    session_name = var.aws_session_name
  }

  alias = "workload_2"
}

provider "aws" {
  region = var.aws_region_sso
  alias  = "sso"

  # Assume role in Master account
  assume_role {
    role_arn     = "arn:aws:iam::${var.master_account_id}:role/${var.prime_role_name}"
    session_name = var.aws_session_name
  }
}

# USA
provider "aws" {
  region = "us-east-1"
  alias  = "workload_us-east-1"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
    session_name = var.aws_session_name
  }
}

provider "aws" {
  region = "us-east-2"
  alias  = "workload_us-east-2"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
    session_name = var.aws_session_name
  }
}

provider "aws" {
  region = "us-west-1"
  alias  = "workload_us-west-1"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
    session_name = var.aws_session_name
  }
}

provider "aws" {
  region = "us-west-2"
  alias  = "workload_us-west-2"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
    session_name = var.aws_session_name
  }
}

terraform {
  backend "s3" {
  }
}
