# output "aws_auth_configmap" {
#   value = data.template_file.aws_auth_configmap.rendered
# }

output "cluster_name" {
  value = var.cluster_name
}

output "kubeconfig_admin" {
  value = data.template_file.kubeconfig_admin.rendered
}

output "kubeconfig_saml" {
  value = data.template_file.kubeconfig_saml.rendered
}