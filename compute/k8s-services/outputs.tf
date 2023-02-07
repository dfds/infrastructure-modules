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

output "traefik_dashboard_url" {
  value = var.traefik_flux_deploy ? "https://traefik.${var.eks_cluster_name}.${var.workload_dns_zone_name}/dashboard/" : "Not enabled in service configuration."
}

output "grafana_url" {
  value = var.monitoring_kube_prometheus_stack_deploy ? "https://grafana.${var.eks_cluster_name}.${var.workload_dns_zone_name}${var.monitoring_kube_prometheus_stack_grafana_ingress_path}" : "Not enabled in service configuration."
}
