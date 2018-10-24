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

resource "aws_route53_record" "nsrecord" {
    # This will create the record of type NS that enables a sub domain to be queried
    zone_id = "${var.aws_dns_id}"
    name    = "${var.aws_dns_zone}"
    type    = "NS"
    ttl     = "30"

    records = [
        "${var.route53-zone-ns0}",
        "${var.route53-zone-ns1}",
        "${var.route53-zone-ns2}",
        "${var.route53-zone-ns3}",
    ]
}