provider "aws" {
  region = var.aws_region
}

provider "aws" {
  region = var.aws_region
  alias  = "workload"

  assume_role {
    role_arn = "arn:aws:iam::${var.aws_workload_account_id}:role/${var.prime_role_name}"
  }
}

terraform {
  backend "s3" {}
}

# Create zone in workload account
module "route53_zone" {
  source        = "../../_sub/network/route53-zone"
  dns_zone_name = var.dns_zone_name

  providers = {
    aws = aws.workload
  }
}

# Delegate zone in core account
module "route53_delegate_zone" {
  source              = "../../_sub/network/route53-delegate-zone"
  dns_child_zone_name = var.dns_zone_name
  dns_zone_id         = data.aws_route53_zone.parent.zone_id
  dns_zone_ns         = module.route53_zone.dns_zone_ns
}
