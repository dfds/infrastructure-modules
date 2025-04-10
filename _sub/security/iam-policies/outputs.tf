output "admin" {
  value = data.aws_iam_policy_document.admin.json
}

output "ssoreader" {
  value = data.aws_iam_policy_document.ssoreader.json
}

output "ssussm" {
  value = data.aws_iam_policy_document.ssussm.json
}

output "vpcreader" {
  value = data.aws_iam_policy_document.vpcreader.json
}

output "push_to_ecr" {
  value = data.aws_iam_policy_document.push_to_ecr.json
}

output "create_org_account" {
  value = data.aws_iam_policy_document.create_org_account.json
}

output "trusted_account" {
  value = element(
    concat(data.aws_iam_policy_document.trusted_account[*].json, [""]),
    0,
  )
}

output "assume_noncore_accounts" {
  value = data.aws_iam_policy_document.assume_noncore_accounts.json
}

output "access_cloudwatchlogs_capability" {
  value = data.aws_iam_policy_document.access_cloudwatchlogs_capability.json
}

output "access_cloudwatchlogs_devops" {
  value = data.aws_iam_policy_document.access_cloudwatchlogs_devops.json
}

output "capability_access_shared" {
  value = data.aws_iam_policy_document.capability_access_shared.json
}

output "certero_endpoint" {
  value = data.aws_iam_policy_document.certero_endpoint.json
}

output "certero_endpoint_for_master_account" {
  value = data.aws_iam_policy_document.certero_endpoint_for_master_account.json
}
