output "alb_fqdn" {
  value       = element(concat(aws_lb.traefik[*].dns_name, [""]), 0)
  description = "The fully-qualified domain name of the Traefik ALB."
}

output "alb_name" {
  value       = aws_lb.traefik.name
  description = "The name of the Traefik ALB."
}

output "alb_arn" {
  value       = aws_lb.traefik.arn
  description = "The ARN of the Traefik ALB."
}

output "alb_arn_suffix" {
  value       = aws_lb.traefik.arn_suffix
  description = "The ARN suffix of the Traefik ALB."
}

output "alb_target_group_arn_suffix_blue" {
  value       = aws_lb_target_group.traefik_blue_variant.arn_suffix
  description = "The ARN suffix of the Traefik blue variant target group."
}

output "alb_target_group_arn_suffix_green" {
  value       = aws_lb_target_group.traefik_green_variant.arn_suffix
  description = "The ARN suffix of the Traefik green variant target group."
}
