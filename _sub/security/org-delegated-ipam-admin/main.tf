resource "aws_vpc_ipam_organization_admin_account" "this" {
  delegated_admin_account_id = var.account_id
}
