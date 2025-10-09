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
