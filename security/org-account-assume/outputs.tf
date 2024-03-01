output "email" {
  value = module.org_account.email
}

output "id" {
  value = module.org_account.id
}

output "name" {
  value = module.org_account.name
}

output "org_role_name" {
  value = module.org_account.org_role_name
}

output "org_role_arn" {
  value = module.org_account.org_role_arn
}

output "grafana_cloud_cloudwatch_integration_role" {
  value = try(module.iam_role_grafana_cloud_cloudwatch.role_arn, null)
}
