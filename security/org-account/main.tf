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

####################################################################################################################
# Following providers are needed to deploy Resource Explorer in all available regions
####################################################################################################################
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
####################################################################################################################

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

# --------------------------------------------------
# AWS Resource Explorer Feature
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

# resource "aws_resourceexplorer2_index" "ap-south-1" {
#   type = "LOCAL"

#   provider = aws.workload_ap-south-1
# }

# resource "aws_resourceexplorer2_index" "ap-northeast-3" {
#   type = "LOCAL"

#   provider = aws.workload_ap-northeast-3
# }

# resource "aws_resourceexplorer2_index" "ap-northeast-2" {
#   type = "LOCAL"

#   provider = aws.workload_ap-northeast-2
# }

# resource "aws_resourceexplorer2_index" "ap-southeast-1" {
#   type = "LOCAL"

#   provider = aws.workload_ap-southeast-1
# }
# resource "aws_resourceexplorer2_index" "ap-southeast-2" {
#   type = "LOCAL"

#   provider = aws.workload_ap-southeast-2
# }
# resource "aws_resourceexplorer2_index" "ap-northeast-1" {
#   type = "LOCAL"

#   provider = aws.workload_ap-northeast-1
# }

# resource "aws_resourceexplorer2_index" "ca-central-1" {
#   type = "LOCAL"

#   provider = aws.workload_ca-central-1
# }

resource "aws_resourceexplorer2_index" "eu-west-1" {
  type = "LOCAL"

  provider = aws.workload_eu-west-1
}

resource "aws_resourceexplorer2_index" "eu-west-2" {
  type = "LOCAL"

  provider = aws.workload_eu-west-2
}

resource "aws_resourceexplorer2_index" "eu-west-3" {
  type = "LOCAL"

  provider = aws.workload_eu-west-3
}

# resource "aws_resourceexplorer2_index" "eu-north-1" {
#   type = "LOCAL"

#   provider = aws.workload_eu-north-1
# }


# resource "aws_resourceexplorer2_index" "sa-east-1" {
#   type = "LOCAL"

#   provider = aws.workload_sa-east-1
# }