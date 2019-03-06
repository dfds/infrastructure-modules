# --------------------------------------------------
# Traefik
# --------------------------------------------------

output "traefik_alb_anon_dns_name" {
    value = "${element(concat(module.traefik_alb_anon_dns.record_name, list("")), 0)}.${var.workload_dns_zone_name}"
}

output "traefik_alb_auth_dns_name" {
    value = "${element(concat(module.traefik_alb_auth_dns.record_name, list("")), 0)}.${var.workload_dns_zone_name}"
}


# --------------------------------------------------
# ArgoCD
# --------------------------------------------------

output "argocd_endpoint" {
  value = "${module.argocd_deploy.external_url}"
}

output "argocd_grpc_endpoint" {
  value = "${module.argocd_deploy.grpc_host_url}"
}