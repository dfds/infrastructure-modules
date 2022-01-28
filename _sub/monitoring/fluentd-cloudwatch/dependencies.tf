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
# Monitoring
# --------------------------------------------------

locals {
  cluster_repo_path = "clusters/${var.cluster_name}"
  config_repo_path  = "platform-apps/${var.cluster_name}/${var.deploy_name}/config"
  app_install_name  = "platform-apps-${var.deploy_name}"

  app_config_path = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1beta2"
    "kind"       = "Kustomization"
    "metadata" = {
      "name"      = "${local.app_install_name}-config"
      "namespace" = "flux-system"
    }
    "spec" = {
      "interval" = "1m0s"
      "sourceRef" = {
        "kind" = "GitRepository"
        "name" = "flux-system"
      }
      "path"  = "./${local.config_repo_path}"
      "prune" = true
    }
  }

  config_init = {
    "apiVersion" = "kustomize.config.k8s.io/v1beta1"
    "kind"       = "Kustomization"
    "resources" = [
      "https://github.com/dfds/platform-apps/apps/${var.deploy_name}"
    ]
    "images" = [
      {
        "name"   = "fluent/fluentd-kubernetes-daemonset",
        "newTag" = "v1.11-debian-cloudwatch-1"
      }
    ]
    "patchesStrategicMerge" = [
      "patch.yaml"
    ]
  }

  config_patch_yaml = <<YAML
---
apiVersion: v1
kind: Namespace
metadata:
  name: fluentd
  annotations:
    iam.amazonaws.com/permitted: arn:aws:iam::${var.aws_workload_account_id}:role/eks-${var.cluster_name}-cloudwatchlogs

---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: fluentd-cloudwatch
  namespace: fluentd
spec:
  template:
    metadata:
      annotations:
        iam.amazonaws.com/role: arn:aws:iam::${var.aws_workload_account_id}:role/eks-${var.cluster_name}-cloudwatchlogs
    spec:
      containers:
        - name: fluentd-cloudwatch
          env:
            - name: AWS_REGION
              value: "${var.aws_region}"
            - name: RETENTION_IN_DAYS
              value: "7"

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-cloudwatch
  namespace: fluentd
data:
  02-tag.conf: |-
    # Tag with namespace and prefix with clustername
    <match kubernetes.**>
      @type rewrite_tag_filter
      <rule>
        key $.kubernetes.namespace_name
        pattern ^(.+)$
        tag /k8s/${var.cluster_name}/$1
      </rule>
    </match>
  YAML
}
