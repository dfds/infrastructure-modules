provider "aws" {
    # The AWS region in which all resources will be created
    version = "~> 1.40"
}

terraform {
    # The configuration for this backend will be filled in by Terragrunt
    backend "s3" {}
    required_version = "~> 0.11.7"
}

resource "aws_route53_record" "ns" {
    # This will create the record of type NS that enables a sub domain to be queried
    zone_id = "${var.dns_zone_id}"
    name    = "${var.dns_child_zone_name}"
    type    = "NS"
    ttl     = "300"

    records = ["${var.dns_zone_ns}"]
}