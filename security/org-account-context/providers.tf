provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }

  # Assume role in Master account
  assume_role {
    role_arn     = "arn:aws:iam::${var.master_account_id}:role/${var.prime_role_name}"
    session_name = var.aws_session_name
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "core" # this provider does not seem to be used?

  default_tags {
    tags = var.tags
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "shared"

  default_tags {
    tags = var.tags
  }

  # Assume role in Shared account
  assume_role {
    role_arn     = "arn:aws:iam::${var.shared_account_id}:role/${var.prime_role_name}"
    session_name = var.aws_session_name
  }
}

provider "aws" {
  region = "eu-west-1"
  alias  = "shared_vpc"

  default_tags {
    tags = var.tags
  }

  # Assume role in Shared account
  assume_role {
    role_arn     = "arn:aws:iam::${var.shared_account_id}:role/${var.prime_role_name}"
    session_name = var.aws_session_name
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "workload"

  default_tags {
    tags = var.tags
  }

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn     = module.org_account.org_role_arn
    session_name = var.aws_session_name
  }
}

provider "aws" {
  region = var.aws_region_2
  alias  = "workload_2"

  default_tags {
    tags = var.tags
  }

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn     = module.org_account.org_role_arn
    session_name = var.aws_session_name
  }
}

provider "aws" {
  region = var.aws_region_sso
  alias  = "sso"

  default_tags {
    tags = var.tags
  }

  # Assume role in Master account
  assume_role {
    role_arn     = "arn:aws:iam::${var.master_account_id}:role/${var.prime_role_name}"
    session_name = var.aws_session_name
  }
}

# EU
provider "aws" {
  region = "eu-central-1"
  alias  = "workload_eu-central-1"

  default_tags {
    tags = var.tags
  }

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn     = module.org_account.org_role_arn
    session_name = var.aws_session_name
  }
}

provider "aws" {
  region = "eu-west-1"
  alias  = "workload_eu-west-1"

  default_tags {
    tags = var.tags
  }

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn     = module.org_account.org_role_arn
    session_name = var.aws_session_name
  }
}

provider "aws" {
  region = "eu-west-2"
  alias  = "workload_eu-west-2"

  default_tags {
    tags = var.tags
  }

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn     = module.org_account.org_role_arn
    session_name = var.aws_session_name
  }
}

provider "aws" {
  region = "eu-west-3"
  alias  = "workload_eu-west-3"

  default_tags {
    tags = var.tags
  }

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn     = module.org_account.org_role_arn
    session_name = var.aws_session_name
  }
}

# USA
provider "aws" {
  region = "us-east-1"
  alias  = "workload_us-east-1"

  default_tags {
    tags = var.tags
  }

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn     = module.org_account.org_role_arn
    session_name = var.aws_session_name
  }
}

provider "aws" {
  region = "us-east-2"
  alias  = "workload_us-east-2"

  default_tags {
    tags = var.tags
  }

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn     = module.org_account.org_role_arn
    session_name = var.aws_session_name
  }
}

provider "aws" {
  region = "us-west-1"
  alias  = "workload_us-west-1"

  default_tags {
    tags = var.tags
  }

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn     = module.org_account.org_role_arn
    session_name = var.aws_session_name
  }
}

provider "aws" {
  region = "us-west-2"
  alias  = "workload_us-west-2"

  default_tags {
    tags = var.tags
  }

  # Need explicit credentials in Master, to be able to assume Organizational Role in Workload account
  access_key = var.access_key_master
  secret_key = var.secret_key_master

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn     = module.org_account.org_role_arn
    session_name = var.aws_session_name
  }
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}
