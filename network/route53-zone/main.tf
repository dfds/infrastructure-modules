provider "aws" {
    # The AWS region in which all resources will be created
    region = "${var.aws_region}"

    version = "~> 1.40"
}

terraform {
    # The configuration for this backend will be filled in by Terragrunt
    backend "s3" {}
    required_version = "~> 0.11.7"
}

resource "aws_route53_zone" "dnszone" {
    # This will create a route 53 DNS zone with the hostname provided
    name = "${var.aws_dns_zone}"
}