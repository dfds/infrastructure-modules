data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repo_name}"
}

locals {
  default_repo_branch = data.github_repository.main.default_branch
  repo_branch         = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path   = "clusters/${var.cluster_name}"
  helm_repo_path      = "platform-apps/${var.cluster_name}/${var.deploy_name}/helm"
  app_install_name    = "platform-apps-${var.deploy_name}"
}

locals {
  app_helm_path = <<YAML
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: cluster-reconciler-${var.deploy_name}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: helm-controller
    namespace: ${var.namespace}
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
YAML

  helm_install = <<YAML
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - "${var.gitops_apps_repo_url}/apps/github-arc-ss-controller?ref=${var.gitops_apps_repo_branch}"
patches:
  - path: patch.yaml
    target:
      kind: HelmRelease
      name: ${var.deploy_name}
      namespace: ${var.namespace}
YAML

  helm_patch = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: ${var.deploy_name}
  namespace: ${var.namespace}
spec:
  serviceAccountName: helm-controller
  chart:
    spec:
      version: ${var.helm_chart_version}
YAML

}
