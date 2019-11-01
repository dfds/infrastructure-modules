output "kubeconfig" {
  value = "${local.kubeconfig}"
  sensitive = true
}

output "config-map-aws-auth" {
  value = "${local.config-map-aws-auth}"
}

output "cluster_name" {
  value = "${var.cluster_name}"
}

# output "token" {
#   value = "${data.external.heptio_authenticator_aws.result.token}"
# }

output "admin_configfile" {
  value = "${local.kubeconfig}"
}

output "user_configfile" {
  value = "${local.kubeconfig_users}"
}

output "kubeconfig_path" {
  value = "${var.kubeconfig_path}"
}