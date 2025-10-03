# --------------------------------------------------
# Automatic migration of terraform state
# --------------------------------------------------

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
  from = module.monitoring_namespace[0].kubernetes_namespace.namespace
  to   = module.monitoring_namespace.kubernetes_namespace.namespace
}

moved {
  from = module.monitoring_namespace[0].kubernetes_namespace.namespace
  to   = module.monitoring_namespace.kubernetes_namespace.namespace
}

moved {
  from = module.aws_subnet_exporter[0].aws_iam_role.this
  to   = module.aws_subnet_exporter.aws_iam_role.this
}

moved {
  from = module.aws_subnet_exporter[0].aws_iam_role_policy.this
  to   = module.aws_subnet_exporter.aws_iam_role_policy.this
}

moved {
  from = module.aws_subnet_exporter[0].kubernetes_deployment.this
  to   = module.aws_subnet_exporter.kubernetes_deployment.this
}

moved {
  from = module.aws_subnet_exporter[0].kubernetes_service.this
  to   = module.aws_subnet_exporter.kubernetes_service.this
}

moved {
  from = module.aws_subnet_exporter[0].kubernetes_service_account.this
  to   = module.aws_subnet_exporter.kubernetes_service_account.this
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
  from = module.atlantis_deployment[0].github_repository_file.kubeconfigs[0]
  to   = module.atlantis_deployment[0].github_repository_file.kubeconfigs
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
