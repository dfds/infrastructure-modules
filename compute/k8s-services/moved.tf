moved {
  from = module.monitoring_namespace[0].kubernetes_namespace.namespace
  to   = module.monitoring_namespace.kubernetes_namespace.namespace
}

moved {
  from = module.external_secrets[0].github_repository_file.external-secrets_helm
  to   = module.external_secrets.github_repository_file.external-secrets_helm
}

moved {
  from = module.external_secrets[0].github_repository_file.external-secrets_helm_install
  to   = module.external_secrets.github_repository_file.external-secrets_helm_install
}

moved {
  from = module.external_secrets[0].github_repository_file.external-secrets_helm_patch
  to   = module.external_secrets.github_repository_file.external-secrets_helm_patch
}

moved {
  from = module.external_secrets_ssm[0].aws_iam_policy.this
  to   = module.external_secrets_ssm.aws_iam_policy.this
}

moved {
  from = module.external_secrets_ssm[0].aws_iam_role.this
  to   = module.external_secrets_ssm.aws_iam_role.this
}

moved {
  from = module.external_secrets_ssm[0].aws_iam_role_policy_attachment.this
  to   = module.external_secrets_ssm.aws_iam_role_policy_attachment.this
}

moved {
  from = module.metrics_server[0].github_repository_file.helm
  to   = module.metrics_server.github_repository_file.helm
}

moved {
  from = module.metrics_server[0].github_repository_file.kustomization
  to   = module.metrics_server.github_repository_file.kustomization
}

moved {
  from = module.traefik_variant_flux_manifests
  to   = module.traefik_green_variant_manifests
}

moved {
  from = module.traefik_alb_auth_appreg[0].azuread_application.app
  to   = module.traefik_alb_auth_appreg.azuread_application.app
}

moved {
  from = module.traefik_alb_auth_appreg[0].azuread_service_principal.sp
  to   = module.traefik_alb_auth_appreg.azuread_service_principal.sp
}

moved {
  from = module.traefik_alb_auth_appreg[0].azuread_service_principal_password.key
  to   = module.traefik_alb_auth_appreg.azuread_service_principal_password.key
}

moved {
  from = module.traefik_alb_auth_appreg[0].random_password.password
  to   = module.traefik_alb_auth_appreg.random_password.password
}

moved {
  from = module.traefik_blue_variant_flux_manifests[0].github_repository_file.traefik_helm
  to   = module.traefik_blue_variant_flux_manifests.github_repository_file.traefik_helm
}

moved {
  from = module.traefik_blue_variant_flux_manifests[0].github_repository_file.traefik_helm_install
  to   = module.traefik_blue_variant_flux_manifests.github_repository_file.traefik_helm_install
}

moved {
  from = module.traefik_green_variant_manifests[0].github_repository_file.traefik_helm
  to   = module.traefik_green_variant_manifests.github_repository_file.traefik_helm
}

moved {
  from = module.traefik_green_variant_manifests[0].github_repository_file.traefik_helm_install
  to   = module.traefik_green_variant_manifests.github_repository_file.traefik_helm_install
}
