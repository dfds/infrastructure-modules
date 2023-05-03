output "alb_fqdn" {
  value = element(concat(aws_lb.traefik_auth[*].dns_name, [""]), 0)
}

output "alb_name" {
  value = (var.deploy_blue_variant || var.deploy_green_variant) ? aws_lb.traefik_auth[0].name : ""
}

output "alb_arn" {
  value = (var.deploy_blue_variant || var.deploy_green_variant) ? aws_lb.traefik_auth[0].arn : ""
}

output "alb_arn_suffix" {
  value = (var.deploy_blue_variant || var.deploy_green_variant) ? aws_lb.traefik_auth[0].arn_suffix : ""
}

output "alb_target_group_arn_suffix_blue" {
  value = var.deploy_blue_variant ? aws_lb_target_group.traefik_auth_blue_variant[0].arn_suffix : ""
}

output "alb_target_group_arn_suffix_green" {
  value = var.deploy_green_variant ? aws_lb_target_group.traefik_auth_green_variant[0].arn_suffix : ""
}
