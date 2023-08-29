resource "aws_organizations_delegated_administrator" "this" {
  for_each = { for x in var.delegated_administrators : x.account_id => x }

  account_id        = each.value.account_id
  service_principal = each.value.service_principal
}
