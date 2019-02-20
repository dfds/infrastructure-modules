# output "traefik_alb_fqdn" {
#   value = "${module.eks_alb.alb_fqdn}"
# }

# output "harbor_endpoint" {
#   value = "${module.k8s_harbor.container_registry_endpoint}"
# }

output "eks_worker_role_id" {
    value = "${module.eks_workers.worker_role_id}"
}