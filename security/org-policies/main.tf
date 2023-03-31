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
  policy         = local.preventive_policy
  attach_targets = var.ou_ids_for_preventive_policy
}

module "org_policy_integrity_policy" {
  source         = "../../_sub/security/org-service-control-policy"
  name           = "IntegrityPolicy"
  description    = "Enables us to have better confidence in the information, logs and auditing provided by AWS"
  policy         = local.integrity_policy
  attach_targets = var.ou_ids_for_integrity_policy
}

module "org_policy_restrictive_policy" {
  source         = "../../_sub/security/org-service-control-policy"
  name           = "RestrictivePolicy"
  description    = "Used to stop bad practices in the teams, either when there is an alternative or it has been judged to pose a risk"
  policy         = local.restrictive_policy
  attach_targets = var.ou_ids_for_restrictive_policy
}
