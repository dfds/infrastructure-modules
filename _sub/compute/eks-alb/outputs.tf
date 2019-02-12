output "alb_fqdn" {
  value = "${element(concat(aws_lb.traefik.*.dns_name, list("")), 0)}"
}
