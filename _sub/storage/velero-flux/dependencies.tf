# --------------------------------------------------
# Namespace
# --------------------------------------------------

locals {
  namespace = "flux-system"
}

# --------------------------------------------------
# Github
# --------------------------------------------------

locals {
  known_hosts = "github.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBEmKSENjQEezOmxkZMy7opKgwFB9nkt5YRrYMjNuG5N87uRgg6CLrbo5wAdT/y6v0mKV0U2w0WZ2YB/++Tpockg="
}

data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repo_name}"
}

data "github_branch" "flux_branch" {
  repository = var.repo_name
  branch     = var.repo_branch
}

# --------------------------------------------------
# Velero
# --------------------------------------------------
locals {
  cluster_repo_path = "clusters/${var.cluster_name}"
  helm_repo_path    = "platform-apps/${var.cluster_name}/${var.deploy_name}/helm"
  app_install_name  = "platform-apps-${var.deploy_name}"

  app_helm_path = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1beta2"
    "kind"       = "Kustomization"
    "metadata" = {
      "name"      = "${local.app_install_name}-helm"
      "namespace" = "flux-system"
    }
    "spec" = {
      "interval" = "1m0s"
      "sourceRef" = {
        "kind" = "GitRepository"
        "name" = "flux-system"
      }
      "path"  = "./${local.helm_repo_path}"
      "prune" = true
    }
  }

  helm_init = {
    "apiVersion" = "kustomize.config.k8s.io/v1beta1"
    "kind"       = "Kustomization"
    "resources" = [
      "https://github.com/dfds/platform-apps/apps/${var.deploy_name}"
    ]
    "patchesStrategicMerge" = [
      "patch.yaml"
    ]
  }

  helm_patch_yaml = <<YAML
---
apiVersion: v1
kind: Namespace
metadata:
  name: velero

---
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: velero
  namespace: flux-system
spec:
  chart:
    spec:
      chart: velero
      version: ${var.helm_chart_version}
      sourceRef:
        kind: HelmRepository
        name: ${var.helm_repo_name}
        namespace: flux-system
  values:
    image:
      repository: velero/velero
      tag: ${var.image_tag}
    snapshotsEnabled: ${var.snapshots_enabled}
    initContainers:
      - name: velero-plugin-for-aws
        image: velero/velero-plugin-for-aws:${var.plugin_for_aws_version}
        volumeMounts:
          - mountPath: /target
            name: plugins
      - name: velero-plugin-for-csi
        image: velero/velero-plugin-for-csi:${var.plugin_for_csi_version}
        volumeMounts:
          - mountPath: /target
            name: plugins
    configuration:
      logLevel: ${var.log_level}
      backupStorageLocation:
        bucket: ${var.bucket_name}
    serviceAccount:
      server:
        create: true
        annotations:
          eks.amazonaws.com/role-arn: "${var.role_arn}"
          eks.amazonaws.com/sts-regional-endpoints: "true"
    schedules:
      ${var.cluster_name}-cluster-backup:
        schedule: "${var.cron_schedule}"
        template:
          ttl: "${var.schedules_template_ttl}"
          snapshotVolumes: ${var.schedules_template_snapshot_volumes}
          includeClusterResources: ${var.schedules_template_include_cluster_resources}
  YAML
}
