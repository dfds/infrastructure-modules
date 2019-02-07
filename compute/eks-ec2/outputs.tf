output "alb_fqdn" {
  value = "${module.eks_alb.alb_fqdn}"
}

output "container_registry_endpoint" {
  value = "${module.k8s_container_registry.container_registry_endpoint}"
}
