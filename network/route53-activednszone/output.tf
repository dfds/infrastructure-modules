#Outputs nameservers and zone id for the dns zone
output "route53-zone-hostname" {
  value = "${var.aws_dns_zone}"
}

output "route53-zone-id" {
  value = "${var.aws_dns_id}"
}

#Outputs the 4 default nameservers for the newly created zone
output "route53-zone-ns0" {
    value = "${var.route53-zone-ns0}"
}
output "route53-zone-ns1" {
    value = "${var.route53-zone-ns1}"
}output "route53-zone-ns2" {
    value = "${var.route53-zone-ns2}"
}output "route53-zone-ns3" {
    value = "${var.route53-zone-ns3}"
}