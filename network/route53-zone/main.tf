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
    name = "${var.dns_zone_name}"}

module "route53_delegate_zone" {
    source = "../../_sub/network/route53-delegate-zone"
    dns_child_zone_name = "${var.dns_zone_name}"
    dns_zone_id = "${aws_route53_zone.dnszone.zone_id}"
    dns_zone_ns = ["${aws_route53_zone.dnszone.name_servers}"]
}