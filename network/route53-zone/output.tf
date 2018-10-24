#Outputs nameservers and zone id for the dns zone
output "route53-zone-hostname" {
  value = "${var.aws_dns_zone}"
}

output "route53-zone-id" {
  value = "${aws_route53_zone.dnszone.zone_id}"
}

#Outputs the 4 default nameservers for the newly created zone
output "route53-zone-ns0" {
    value = "${aws_route53_zone.dnszone.name_servers.0}"
}

output "route53-zone-ns1" {
    value = "${aws_route53_zone.dnszone.name_servers.1}"
}output "route53-zone-ns2" {
    value = "${aws_route53_zone.dnszone.name_servers.2}"
}output "route53-zone-ns3" {
    value = "${aws_route53_zone.dnszone.name_servers.3}"
}