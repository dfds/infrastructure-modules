output "nlb_fqdn" {
  value = "${element(concat(aws_lb.nlb.*.dns_name, list("")), 0)}"
}
