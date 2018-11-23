provider "aws" {
    # The AWS region in which all resources will be created
    region = "${var.aws_region}"

    version = "~> 1.40"

    # A Nickname for the account with the root dns
    alias = "rootdns"
}

provider "aws" {
    # The AWS region in which all resources will be created
    region = "${var.aws_region}"

    version = "~> 1.40"

    # A nickname for the account where the new dns zone should be created
    alias = "dnszone"

    #The role to assume to be able to create the dns zone
    assume_role {
        role_arn = "arn:aws:iam::${var.target_account_id}:role/${var.role_to_assume}"
    }
}

# terraform {
#     # The configuration for this backend will be filled in by Terragrunt
#     backend "s3" {}
#     required_version = "~> 0.11.7"
# }

resource "aws_route53_zone" "dnszone" {
    # This will create a route 53 DNS zone with the hostname provided
    name = "${var.aws_dns_zone}.${var.root_dns}"

    provider = "aws.dnszone"
}

resource "aws_route53_record" "nsrecord" {
    # This will create the record of type NS that enables a sub domain to be queried
    zone_id = "${data.aws_route53_zone.selected.zone_id}"
    name    = "${var.aws_dns_zone}"
    type    = "NS"
    ttl     = "30"

    records = [
        "${aws_route53_zone.dnszone.name_servers}"
    ]
    
    provider = "aws.rootdns"
}