module "delegated_ipam_admin" {
  source     = "../../_sub/security/org-delegated-ipam-admin"
  account_id = var.network_account_id
}
