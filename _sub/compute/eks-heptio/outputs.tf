output "kubeconfig" {
  value     = local.kubeconfig
  sensitive = true
}

output "config-map-aws-auth" {
  value = local.config-map-aws-auth
}

output "cluster_name" {
  value = var.cluster_name
}

# output "token" {
#   value = "${data.external.heptio_authenticator_aws.result.token}"
# }

output "admin_configfile" {
  value = local.kubeconfig
}

output "user_configfile" {
  value = local.kubeconfig_users
}

# Hack'ish workaround, until properly supported by Terraform
# Based on https://discuss.hashicorp.com/t/tips-howto-implement-module-depends-on-emulation/2305
# This output is articially calculated, to trick Terraform create an implicit dependency.
output "kubeconfig_path" {
  value = length(data.local_file.kubeconfig.content) > 0 ? var.kubeconfig_path : ""
}
