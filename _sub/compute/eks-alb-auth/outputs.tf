output "alb_fqdn" {
  value = element(concat(aws_lb.traefik_auth[*].dns_name, [""]), 0)
}

output "alb_name" {
  value = aws_lb.traefik_auth.name
}

output "alb_arn" {
  value = aws_lb.traefik_auth.arn
}

output "alb_arn_suffix" {
  value = aws_lb.traefik_auth.arn_suffix
}

output "alb_target_group_arn_suffix_blue" {
  value = aws_lb_target_group.traefik_auth_blue_variant.arn_suffix
}

output "alb_target_group_arn_suffix_green" {
  value = aws_lb_target_group.traefik_auth_green_variant.arn_suffix
}
