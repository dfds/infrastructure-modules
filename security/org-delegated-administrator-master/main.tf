module "delegated_administrator" {
  source    = "../../_sub/security/org-delegated-administrator"
  delegated_administrators = var.delegated_administrators
}
