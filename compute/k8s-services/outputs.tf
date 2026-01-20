# --------------------------------------------------
# Traefik
# --------------------------------------------------

output "traefik_alb_anon_dns_name" {
  value       = "${element(concat(module.traefik_alb_anon_dns.record_name, [""]), 0)}.${var.workload_dns_zone_name}"
  description = "The anonymous DNS name for accessing the Traefik ALB (if enabled)."
}

output "traefik_blue_variant_dashboard_url" {
  value       = var.traefik_blue_variant_deploy ? "https://traefik-blue-variant.${var.eks_cluster_name}.${var.workload_dns_zone_name}/dashboard/" : "Not enabled in service configuration."
  description = "The URL for accessing the Traefik Blue Variant dashboard)."
}

output "traefik_green_variant_dashboard_url" {
  value       = var.traefik_green_variant_deploy ? "https://traefik-green-variant.${var.eks_cluster_name}.${var.workload_dns_zone_name}/dashboard/" : "Not enabled in service configuration."
  description = "The URL for accessing the Traefik Green Variant dashboard."
}
