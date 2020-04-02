output "alb_fqdn" {
  value = element(concat(aws_lb.traefik_auth.*.dns_name, [""]), 0)
}

output "alb_arn_suffix" {
  value = var.deploy ? aws_lb.traefik_auth.*.arn_suffix : [] # output must be a list (even if empty), otherwise concat in k8s-services fails
}
