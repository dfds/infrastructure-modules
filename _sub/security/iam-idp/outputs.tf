output "adfs_assume_policy" {
  value = "${data.aws_iam_policy_document.adfs_assume.json}"
}

output "adfs_role_assume_policy" {
  value = "${data.aws_iam_policy_document.adfs_role_assume.json}"
}