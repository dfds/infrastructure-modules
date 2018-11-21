output "create_org_account" {
    value = "${data.aws_iam_policy_document.create_org_account.json}"
}

output "trusted_account" {
    value = "${data.aws_iam_policy_document.trusted_account.json}"
}