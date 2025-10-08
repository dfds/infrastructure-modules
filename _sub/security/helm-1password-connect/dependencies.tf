data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repo_name}"
}

locals {
  deploy_name         = "1password-connect"
  default_repo_branch = data.github_repository.main.default_branch
  cluster_repo_path   = "clusters/${var.cluster_name}"
  repo_branch         = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  helm_repo_path      = "platform-apps/${var.cluster_name}/${local.deploy_name}/helm"
  app_install_name    = "platform-apps-${local.deploy_name}"
}

locals {
  app_helm_path = <<YAML
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-reconciler-${local.deploy_name}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: helm-controller
  namespace: "1password-connect"
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: "${local.app_install_name}-helm"
  namespace: "flux-system"
spec:
  serviceAccountName: kustomize-controller
  interval: 1m0s
  dependsOn:
    - name: "platform-apps-sources"
  sourceRef:
    kind: GitRepository
    name: "flux-system"
  path: "./${local.helm_repo_path}"
  prune: ${var.prune}
  postBuild:
    substitute:
      fluxcd_aws_region: ${var.aws_region}
      fluxcd_aws_workload_account_id: "${var.workload_account_id}"
YAML

  helm_install = <<YAML
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: "1password-connect"
resources:
  - ${var.gitops_apps_repo_url}/apps/${local.deploy_name}?ref=${var.gitops_apps_repo_branch}
patches:
  - target:
      kind: HelmRelease
      name: 1password-connect
      namespace: 1password-connect
    patch: |-
      - op: replace
        path: /spec/chart/spec/version
        value: "${var.chart_version}"
YAML
}
