provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.tags
  }

  assume_role {
    role_arn = var.aws_assume_role_arn
  }
}

provider "aws" {
  region = var.aws_region
  alias  = "core"

  default_tags {
    tags = var.tags
  }
}
