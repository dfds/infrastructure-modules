output "grafana_token_ssm_parameter_arn" {
  description = "The ARN of the SSM parameter for Grafana 1password token"
  value       = aws_ssm_parameter.grafana[0].arn
}