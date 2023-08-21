# --------------------------------------------------
# Service Control Policies (SCP)
# --------------------------------------------------

module "org_policy_preventive_policy" {
  source         = "../../_sub/security/org-service-control-policy"
  name           = "PreventivePolicy"
  description    = "Enables best practices for keeping accounts secure and limits when a breach occurs"
  policy         = data.aws_iam_policy_document.preventive
  attach_targets = var.preventive_policy_attach_targets
}

module "org_policy_integrity_policy" {
  source         = "../../_sub/security/org-service-control-policy"
  name           = "IntegrityPolicy"
  description    = "Enables us to have better confidence in the information, logs and auditing provided by AWS"
  policy         = data.aws_iam_policy_document.integrity
  attach_targets = var.integrity_policy_attach_targets
}

module "org_policy_restrictive_policy" {
  source         = "../../_sub/security/org-service-control-policy"
  name           = "RestrictivePolicy"
  description    = "Used to stop bad practices in the teams, either when there is an alternative or it has been judged to pose a risk"
  policy         = data.aws_iam_policy_document.restrictive
  attach_targets = var.restrictive_policy_attach_targets
}

module "org_policy_reservation_policy" {
  source         = "../../_sub/security/org-service-control-policy"
  name           = "ReservationPolicy"
  description    = "Enables us to limit teams from committing us to long term reservations"
  policy         = data.aws_iam_policy_document.reservation
  attach_targets = var.reservation_policy_attach_targets
}
