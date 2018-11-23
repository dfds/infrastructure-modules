#Outputs nameservers and zone id for the dns zone
output "aws_dns_zone" {
  value = "${var.aws_dns_zone}.${var.root_dns}"
}

output "sub_route53_zone_id" {
  value = "${aws_route53_zone.dnszone.zone_id}"
}

#Outputs the 4 default nameservers for the newly created zone
output "route53_zone_ns" {
    value = "${aws_route53_zone.dnszone.name_servers}"
}
