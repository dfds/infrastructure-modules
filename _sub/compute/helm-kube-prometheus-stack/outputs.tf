output "grafana_admin_password" {
  value     = var.grafana_admin_password != "" ? "<as supplied in terragrunt.hcl>" : random_password.grafana_password.result
  sensitive = true
}
