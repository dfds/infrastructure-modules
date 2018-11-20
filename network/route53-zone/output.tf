#Outputs nameservers and zone id for the dns zone
output "dns_zone_name" {
  value = "${var.dns_zone_name}"
}

output "dns_zone_id" {
  value = "${aws_route53_zone.dnszone.zone_id}"
}

#Outputs the 4 default nameservers for the newly created zone
output "dns_zone_ns" {
    value = "${aws_route53_zone.dnszone.name_servers}"
}