output "account_ids" {
  value = [for account in data.aws_organizations_organizational_unit_child_accounts.this.accounts : account.id]
}

output "organizational_units" {
  value = [for ou in data.aws_organizations_organizational_unit_descendant_organizational_units.ous.children : ou]
}
