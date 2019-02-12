output "alb_fqdn" {
  value = "${element(concat(aws_lb.traefik_auth.*.dns_name, list("")), 0)}"
}
