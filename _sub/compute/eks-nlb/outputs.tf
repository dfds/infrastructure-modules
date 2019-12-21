output "nlb_fqdn" {
  value = element(concat(aws_lb.nlb.*.dns_name, [""]), 0)
}

