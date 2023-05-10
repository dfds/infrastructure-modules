# --------------------------------------------------
# Namespace
# --------------------------------------------------

resource "null_resource" "flux_namespace" {
  triggers = {
    namespace = local.namespace
  }

  provisioner "local-exec" {
    command = <<-EOT
    kubectl --kubeconfig ${var.kubeconfig_path} create namespace ${self.triggers.namespace}
    kubectl --kubeconfig ${var.kubeconfig_path} label --overwrite namespace ${self.triggers.namespace} pod-security.kubernetes.io/audit=baseline pod-security.kubernetes.io/warn=baseline
    EOT
  }
}


# --------------------------------------------------
# Bootstrap Kubernetes manifests
# --------------------------------------------------

locals {
  install = [for v in data.kubectl_file_documents.install.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
  sync = [for v in data.kubectl_file_documents.sync.documents : {
    data : yamldecode(v)
    content : v
    }
  ]
}

resource "kubectl_manifest" "install" {
  for_each   = { for v in local.install : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  depends_on = [null_resource.flux_namespace]
  yaml_body  = each.value
}

resource "kubectl_manifest" "sync" {
  for_each = { for v in local.sync : lower(join("/", compact([v.data.apiVersion, v.data.kind, lookup(v.data.metadata, "namespace", ""), v.data.metadata.name]))) => v.content }
  # depends_on = [null_resource.wait_crds]
  depends_on = [kubectl_manifest.install]
  yaml_body  = each.value
}


# --------------------------------------------------
# Github
# --------------------------------------------------

resource "tls_private_key" "main" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "kubernetes_secret" "main" {
  depends_on = [kubectl_manifest.install]

  metadata {
    name      = data.flux_sync.main.name
    namespace = data.flux_sync.main.namespace
  }

  data = {
    identity       = tls_private_key.main.private_key_pem
    "identity.pub" = tls_private_key.main.public_key_pem
    known_hosts    = local.known_hosts
  }
}

resource "github_repository_deploy_key" "main" {
  title      = "flux-${var.cluster_name}-readonly"
  repository = data.github_repository.main.name
  key        = tls_private_key.main.public_key_openssh
  read_only  = true
}

resource "github_repository_file" "install" {
  repository          = data.github_repository.main.name
  file                = data.flux_install.main.path
  content             = data.flux_install.main.content
  branch              = data.github_branch.flux_branch.branch
  overwrite_on_create = var.overwrite_on_create

  lifecycle {
    ignore_changes = [
      content # Do not overwrite even if content has changed since bootstrapping Flux
    ]
  }
}

resource "github_repository_file" "sync" {
  repository          = data.github_repository.main.name
  file                = data.flux_sync.main.path
  content             = data.flux_sync.main.content
  branch              = data.github_branch.flux_branch.branch
  overwrite_on_create = var.overwrite_on_create
  depends_on          = [github_repository_file.install]

  lifecycle {
    ignore_changes = [
      content # Do not overwrite even if content has changed since bootstrapping Flux
    ]
  }
}

resource "github_repository_file" "kustomize" {
  repository          = data.github_repository.main.name
  file                = data.flux_sync.main.kustomize_path
  content             = data.flux_sync.main.kustomize_content
  branch              = data.github_branch.flux_branch.branch
  overwrite_on_create = var.overwrite_on_create
  depends_on          = [github_repository_file.sync]

  lifecycle {
    ignore_changes = [
      content # Do not overwrite even if content has changed since bootstrapping Flux
    ]
  }
}


# --------------------------------------------------
# Monitoring
# --------------------------------------------------

resource "github_repository_file" "flux_monitoring_config_path" {
  repository          = var.repository_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.cluster_target_path}/${local.app_install_name}.yaml"
  content             = jsonencode(local.app_config_path)
  overwrite_on_create = var.overwrite_on_create
}

# --------------------------------------------------
# Initializing platform-apps
# --------------------------------------------------

resource "github_repository_file" "platform_apps_init" {
  repository          = var.repository_name
  branch              = data.github_branch.flux_branch.branch
  file                = "${local.cluster_target_path}/platform-apps.yaml"
  content             = local.platform_apps_yaml
  overwrite_on_create = var.overwrite_on_create
}
