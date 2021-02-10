output "grafana_admin_password" {
  value = var.grafana_admin_password != "" ? "You already know it..." : random_password.grafana_password.result
}