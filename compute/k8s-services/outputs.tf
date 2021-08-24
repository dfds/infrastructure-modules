# --------------------------------------------------
# Prometheus Stack
# --------------------------------------------------

output "prometheus_grafana_admin_password" {
  value     = try(module.monitoring_kube_prometheus_stack[0].grafana_admin_password, "")
  sensitive = true
}

# --------------------------------------------------
# Traefik
# --------------------------------------------------

output "traefik_alb_anon_dns_name" {
  value = "${element(concat(module.traefik_alb_anon_dns.record_name, [""]), 0)}.${var.workload_dns_zone_name}"
}

output "traefik_alb_auth_dns_name" {
  value = "${element(concat(module.traefik_alb_auth_dns.record_name, [""]), 0)}.${var.workload_dns_zone_name}"
}

output "traefik_dashboard_secure_url" {
  value = try("https://${module.traefik_deploy.dashboard_ingress_host}/dashboard/", "Not enabled in service configuration.")
}

output "traefik_flux_dashboard_external_url" {
  # try() can't be used on module outputs due to: module.traefik_flux_manifests is a list of object, known only after apply
  value = var.traefik_flux_dashboard_deploy ? "https://${local.traefik_flux_dashboard_ingress_host}/dashboard/" : "Not enabled in service configuration."
}
