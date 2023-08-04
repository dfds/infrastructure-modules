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

# EU
provider "aws" {
  region = "eu-west-1"
  alias  = "workload_eu-west-1"


  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}
provider "aws" {
  region = "eu-west-2"
  alias  = "workload_eu-west-2"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}
provider "aws" {
  region = "eu-west-3"
  alias  = "workload_eu-west-3"


  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region = "eu-north-1"
  alias  = "workload_eu-north-1"


  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

# USA
provider "aws" {
  region = "us-east-1"
  alias  = "workload_us-east-1"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region = "us-east-2"
  alias  = "workload_us-east-2"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region = "us-west-1"
  alias  = "workload_us-west-1"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region = "us-west-2"
  alias  = "workload_us-west-2"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

# Asia Pacific
provider "aws" {
  region = "ap-south-1"
  alias  = "workload_ap-south-1"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region = "ap-northeast-3"
  alias  = "workload_ap-northeast-3"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region = "ap-northeast-2"
  alias  = "workload_ap-northeast-2"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region = "ap-southeast-1"
  alias  = "workload_ap-southeast-1"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region = "ap-southeast-2"
  alias  = "workload_ap-southeast-2"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

provider "aws" {
  region = "ap-northeast-1"
  alias  = "workload_ap-northeast-1"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

# Canada
provider "aws" {
  region = "ca-central-1"
  alias  = "workload_ca-central-1"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

# South America
provider "aws" {
  region = "sa-east-1"
  alias  = "workload_sa-east-1"

  # Assume the Organizational role in Workload account
  assume_role {
    role_arn = module.org_account.org_role_arn
  }
}

terraform {
  # The configuration for this backend will be filled in by Terragrunt
  backend "s3" {
  }
}
