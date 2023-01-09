

output "cluster_name" {
  value = var.cluster_name
}

output "kubeconfig_admin" {
  value = local.kubeconfig_admin_template
}

output "kubeconfig_saml" {
  value = local.kubeconfig_saml_template
}