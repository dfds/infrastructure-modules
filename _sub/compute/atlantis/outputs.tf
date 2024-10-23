output "dashboard_password" {
  value = random_password.password.result
}

output "webhook_secret" {
  value = random_password.webhook.result
}
