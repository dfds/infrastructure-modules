data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repo_name}"
}

data "aws_caller_identity" "this" {
}

locals {
  deploy_name         = "arc-runner-set"
  default_repo_branch = data.github_repository.main.default_branch
  repo_branch         = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path   = "clusters/${var.cluster_name}"
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
    namespace: arc-runners
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
    - name: platform-apps-sources
    - name: platform-apps-arc-helm
  sourceRef:
    kind: GitRepository
    name: "flux-system"
  path: "./${local.helm_repo_path}"
  prune: ${var.prune}
  postBuild:
    substitute:
      flux_github_arc_runners_resource_memory: "${var.runner_resource_memory}"
      flux_github_arc_runners_scale_set_name: "${var.runner_scale_set_name}"
      flux_workload_account_id: "${data.aws_caller_identity.this.id}"
YAML

  helm_install = <<YAML
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - "${var.gitops_apps_repo_url}/apps/github-arc-runners?ref=${var.gitops_apps_repo_ref}"
YAML

}
