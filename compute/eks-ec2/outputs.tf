# --------------------------------------------------
# DNS
# --------------------------------------------------

output "workload_dns_zone_name" {
    value = "${var.workload_dns_zone_name}"
}

output "workload_dns_zone_id" {
    value = "${local.workload_dns_zone_id}"
}

output "core_dns_zone_name" {
    value = "${local.core_dns_zone_name}"
}

output "core_dns_zone_id" {
    value = "${local.core_dns_zone_id}"
}

# --------------------------------------------------
# EKS
# --------------------------------------------------

output "eks_worker_role_id" {
    value = "${module.eks_workers.worker_role_id}"
}

# --------------------------------------------------
# Traefik
# --------------------------------------------------

output "traefik_alb_anon_dns_name" {
    value = "${element(concat(module.traefik_alb_anon_dns.record_name, list("")), 0)}"
}
output "traefik_alb_auth_dns_name" {
    value = "${element(concat(module.traefik_alb_auth_dns.record_name, list("")), 0)}"
}