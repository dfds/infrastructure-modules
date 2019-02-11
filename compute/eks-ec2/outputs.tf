output "alb_fqdn" {
  value = "${module.eks_alb.alb_fqdn}"
}

# output "harbor_endpoint" {
#   value = "${module.k8s_harbor.container_registry_endpoint}"
# }
