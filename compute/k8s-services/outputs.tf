# --------------------------------------------------
# Prometheus Stack
# --------------------------------------------------

output "prometheus_grafana_admin_password" {
  value = try(module.monitoring_kube_prometheus_stack[0].grafana_admin_password, "")
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
