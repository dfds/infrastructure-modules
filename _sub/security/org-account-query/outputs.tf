output "account_ids" {
  value = [for account in data.aws_organizations_organizational_unit_child_accounts.this.accounts : account.id]
}
