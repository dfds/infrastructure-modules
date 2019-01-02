provider "aws" {
  region  = "${var.aws_region}"
  version = "~> 1.40"
  alias   = "core"
}

provider "aws" {
  region = "${var.aws_region}"

  version = "~> 1.40"

  alias = "workload"

  assume_role {
    role_arn = "arn:aws:iam::${var.workload_account_id}:role/${var.prime_role_name}"
  }
}


terraform {
    # The configuration for this backend will be filled in by Terragrunt
    backend "s3" {}
    required_version = "~> 0.11.7"
}


# Create zone in workload account
module "route53_zone" {
    source = "../../_sub/network/route53-zone"
    dns_zone_name = "${var.dns_zone_name}"
  providers = {
    aws = "aws.workload"
  }
}

# Delegate zone in core account
module "route53_delegate_zone" {
    source = "../../_sub/network/route53-delegate-zone"
    dns_child_zone_name = "${var.dns_zone_name}"
    dns_zone_id = "${data.aws_route53_zone.parent.zone_id}"
    dns_zone_ns = "${module.route53_zone.dns_zone_ns}"

  providers = {
    aws = "aws.core"
  }
}
