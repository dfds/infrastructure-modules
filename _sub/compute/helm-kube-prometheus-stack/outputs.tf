output "grafana_admin_password" {
  value = var.grafana_enabled ? "This value is stored in the AWS SSM Parameter Store at ${aws_ssm_parameter.param_grafana_password.name}" : ""
}
