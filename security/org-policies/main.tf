# --------------------------------------------------
# Init
# --------------------------------------------------

provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
  }
}

# --------------------------------------------------
# Service Control (Organization) Policies
# --------------------------------------------------

module "org_policy_preventive_policy" {
  source         = "../../_sub/security/org-service-control-policy"
  name           = "PreventivePolicy"
  description    = "Enables best practices for keeping accounts secure and limits when a breach occurs"
  policy         = jsonencode(jsondecode(file("${path.module}/policies/PreventivePolicy.json")))
  attach_targets = var.preventive_policy_attach_targets
}

module "org_policy_integrity_policy" {
  source         = "../../_sub/security/org-service-control-policy"
  name           = "IntegrityPolicy"
  description    = "Enables us to have better confidence in the information, logs and auditing provided by AWS"
  policy         = jsonencode(jsondecode(file("${path.module}/policies/IntegrityPolicy.json")))
  attach_targets = var.integrity_policy_attach_targets
}

# TODO: Issue https://github.com/dfds/cloudplatform/issues/1504 is scheduled for August to remove DenyBillingLegacyRemoveAfterJuly2023
module "org_policy_restrictive_policy" {
  source         = "../../_sub/security/org-service-control-policy"
  name           = "RestrictivePolicy"
  description    = "Used to stop bad practices in the teams, either when there is an alternative or it has been judged to pose a risk"
  policy         = jsonencode(jsondecode(file("${path.module}/policies/RestrictivePolicy.json")))
  attach_targets = var.restrictive_policy_attach_targets
}

module "org_policy_reservation_policy" {
  source         = "../../_sub/security/org-service-control-policy"
  name           = "ReservationPolicy"
  description    = "Enables us to limit teams from committing us to long term reservations"
  policy         = jsonencode(jsondecode(file("${path.module}/policies/ReservationPolicy.json")))
  attach_targets = var.reservation_policy_attach_targets
}
