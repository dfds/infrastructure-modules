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

  clusters = { for item in var.kafka_clusters : item.id => {
    original = item
    manifest = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2
kind: HelmRelease
metadata:
  name: ${var.deploy_name}-${item.id}
  namespace: ${var.namespace}
spec:
  releaseName: ${var.deploy_name}-${item.id}
  serviceAccountName: helm-controller
  driftDetection:
    mode: enabled
  chart:
    spec:
      chart: chart
      reconcileStrategy: Revision
      sourceRef:
        kind: GitRepository
        name: kafka-exporter
        namespace: flux-system
  interval: 1m0s
  install:
    remediation:
      retries: 3
  values:
    version: ${var.helm_chart_version}
    app:
      config:
        kafkaSecretRef: ${var.deploy_name}-${item.id}
      cluster:
        id: ${item.id}
        environment: ${item.environment}
    priorityClassName: cluster-observability
YAML
  } }

  dyn_clusters_file_list = [for key, value in local.clusters : "\"manifest-${key}.yaml\""]
  clusters_mapped        = join("\n  - ", local.dyn_clusters_file_list)

  helm_install = <<YAML
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ${local.clusters_mapped}
YAML


}
