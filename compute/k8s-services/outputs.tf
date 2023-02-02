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
  # try() can't be used on module outputs due to: module.traefik_flux_manifests is a list of object, known only after apply
  value = var.traefik_flux_dashboard_deploy ? "https://${local.traefik_flux_dashboard_ingress_host}/dashboard/" : "Not enabled in service configuration."
}

output "grafana_url" {
  value = var.monitoring_kube_prometheus_stack_deploy ? "https://grafana.${var.eks_cluster_name}.${var.workload_dns_zone_name}${var.monitoring_kube_prometheus_stack_grafana_ingress_path}" : "Not enabled in service configuration."
}
