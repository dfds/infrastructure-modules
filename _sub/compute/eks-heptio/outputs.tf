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

# Hack'ish workaround, until properly supported by Terraform
# Based on https://discuss.hashicorp.com/t/tips-howto-implement-module-depends-on-emulation/2305
# This output is articially calculated, to trick Terraform create an implicit dependency.
output "kubeconfig_path" {
  value = length(data.local_file.kubeconfig_admin.content) > 0 ? var.kubeconfig_path : ""
}
