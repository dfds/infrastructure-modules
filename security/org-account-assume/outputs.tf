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

output "grafana_cloud_cloudwatch_integration_iam_role_arn" {
  value = try(module.grafana_cloud_cloudwatch_integration[0].arn, "Not used for this account")
}
