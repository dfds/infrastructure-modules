# --------------------------------------------------
# Service Control Policies (SCP)
# --------------------------------------------------

module "org_policy_preventive_policy" {
  source         = "../../_sub/security/org-service-control-policy"
  name           = "PreventivePolicy"
  description    = "Enables best practices for keeping accounts secure and limits when a breach occurs"
  policy         = jsonencode(jsondecode(data.aws_iam_policy_document.preventive.json))
  attach_targets = var.preventive_policy_attach_targets
}

module "org_policy_integrity_policy" {
  source         = "../../_sub/security/org-service-control-policy"
  name           = "IntegrityPolicy"
  description    = "Enables us to have better confidence in the information, logs and auditing provided by AWS"
  policy         = jsonencode(jsondecode(data.aws_iam_policy_document.integrity.json))
  attach_targets = var.integrity_policy_attach_targets
}

module "org_policy_restrictive_policy" {
  source         = "../../_sub/security/org-service-control-policy"
  name           = "RestrictivePolicy"
  description    = "Used to stop bad practices in the teams, either when there is an alternative or it has been judged to pose a risk"
  policy         = jsonencode(jsondecode(data.aws_iam_policy_document.restrictive.json))
  attach_targets = var.restrictive_policy_attach_targets
}

module "org_policy_reservation_policy" {
  source         = "../../_sub/security/org-service-control-policy"
  name           = "ReservationPolicy"
  description    = "Enables us to limit teams from committing us to long term reservations"
  policy         = jsonencode(jsondecode(data.aws_iam_policy_document.reservation.json))
  attach_targets = var.reservation_policy_attach_targets
}

module "org_policy_trustedadvisor_policy" {
  source         = "../../_sub/security/org-service-control-policy"
  name           = "TrustedAdvisorPolicy"
  description    = "Used to control which actions can be performed with Trusted Advisor"
  policy         = jsonencode(jsondecode(data.aws_iam_policy_document.trustedadvisor.json))
  attach_targets = var.trustedadvisor_policy_attach_targets
}