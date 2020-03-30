output "alb_fqdn" {
  value = element(concat(aws_lb.traefik_auth.*.dns_name, [""]), 0)
}

output "alb_arn_suffix" {
  value = "${aws_lb.traefik_auth.*.arn_suffix}"
}

