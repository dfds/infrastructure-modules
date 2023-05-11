#!/bin/bash

WORKDIR=$(pwd)
PARENT_DIR="${1:-$WORKDIR}"

cd "$PARENT_DIR/k8s-qa/cluster" || return

echo "Finding KUBECONFIG..."

unset KUBECONFIG
KUBECONFIG=$(terragrunt output --raw kubeconfig_path)
export KUBECONFIG

echo "KUBECONFIG=$KUBECONFIG"

cd "$PARENT_DIR/k8s-qa/services" || return

echo "Testing migration of Flux CD bootstrap resources..."

terragrunt init -upgrade

terragrunt state rm module.platform_fluxcd[0].null_resource.flux_namespace
terragrunt state rm module.platform_fluxcd[0].kubectl_manifest.install
terragrunt state rm module.platform_fluxcd[0].kubectl_manifest.sync
terragrunt state rm module.platform_fluxcd[0].kubernetes_secret.main
terragrunt state rm module.platform_fluxcd[0].data.flux_install.main
terragrunt state rm module.platform_fluxcd[0].data.flux_sync.main
terragrunt state rm module.platform_fluxcd[0].data.kubectl_file_documents.install
terragrunt state rm module.platform_fluxcd[0].data.kubectl_file_documents.sync
terragrunt state rm module.platform_fluxcd[0].github_repository_file.install
terragrunt state rm module.platform_fluxcd[0].github_repository_file.kustomize
terragrunt state rm module.platform_fluxcd[0].github_repository_file.sync

terragrunt state mv module.platform_fluxcd[0].data.github_branch.flux_branch module.platform_fluxcd.data.github_branch.flux_branch
terragrunt state mv module.platform_fluxcd[0].data.github_repository.main module.platform_fluxcd.data.github_repository.main
terragrunt state mv module.platform_fluxcd[0].github_repository_deploy_key.main module.platform_fluxcd.github_repository_deploy_key.main
terragrunt state mv module.platform_fluxcd[0].github_repository_file.flux_monitoring_config_path module.platform_fluxcd.github_repository_file.flux_monitoring_config_path
terragrunt state mv module.platform_fluxcd[0].github_repository_file.platform_apps_init module.platform_fluxcd.github_repository_file.platform_apps_init
terragrunt state mv module.platform_fluxcd[0].tls_private_key.main module.platform_fluxcd.tls_private_key.main

terragrunt import module.platform_fluxcd.flux_bootstrap_git.this flux-system
