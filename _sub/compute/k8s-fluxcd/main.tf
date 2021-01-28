# --------------------------------------------------
# Namespace
# --------------------------------------------------

resource "null_resource" "flux_namespace" {
  triggers = {
    namespace  = local.namespace
    kubeconfig = var.kubeconfig_path # Variables cannot be accessed by destroy-phase provisioners, only the 'self' object (including triggers)
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${self.triggers.kubeconfig} create namespace ${self.triggers.namespace}"
  }

  /*
  Marking the flux-system namespace for deletion, will cause finalizers to be applied for any Flux CRDs in use.
  The finalize controllers however have been deleted, causing namespace and CRDs to be stuck 'terminating'.
  */

  provisioner "local-exec" {
    when       = destroy
    # Mark the namespace for deletion and wait an abitrary amount of time for cascade delete to remove workloads managed by Flux.
    command    = "kubectl --kubeconfig ${self.triggers.kubeconfig} delete namespace ${self.triggers.namespace} --cascade=true --wait=false && sleep 120"
  }

  provisioner "local-exec" {
    when       = destroy
    # Remove any finalizers from Flux CRDs, allowing these and the namespace to transition from 'terminating' and actually be deleted.
    command    = "kubectl --kubeconfig ${self.triggers.kubeconfig} patch customresourcedefinition helmcharts.source.toolkit.fluxcd.io helmreleases.helm.toolkit.fluxcd.io helmrepositories.source.toolkit.fluxcd.io kustomizations.kustomize.toolkit.fluxcd.io -p '{\"metadata\":{\"finalizers\":null}}'"
    on_failure = continue
  }
}


# --------------------------------------------------
# Bootstrap Kubernetes manifests
# --------------------------------------------------

resource "kubectl_manifest" "install" {
  for_each   = { for v in data.kubectl_file_documents.install.documents : sha1(v) => v }
  depends_on = [null_resource.flux_namespace]

  yaml_body = each.value
}
resource "kubectl_manifest" "sync" {
  for_each   = { for v in data.kubectl_file_documents.sync.documents : sha1(v) => v }
  depends_on = [kubectl_manifest.install, null_resource.flux_namespace]

  yaml_body = each.value
}


# --------------------------------------------------
# Github
# --------------------------------------------------

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
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
  title      = "flux-readonly"
  repository = data.github_repository.main.name
  key        = tls_private_key.main.public_key_openssh
  read_only  = true
}

resource "github_repository_file" "install" {
  repository = data.github_repository.main.name
  file       = data.flux_install.main.path
  content    = data.flux_install.main.content
  branch     = data.github_repository.main.default_branch

  /*
  Add arbitrary pause after installing CRDs, to prevent error like this, because CRD doesn't exist when sync'ing:
  Error: flux-system/flux-system failed to run apply: error when creating "/tmp/875186376kubectl_manifest.yaml": the server could not find the requested resource (post kustomizations.kustomize.toolkit.fluxcd.io)
  */
  provisioner "local-exec" {
    command = "sleep 60"
  }

  lifecycle {
    ignore_changes = [
      content # Do not overwrite even if content has changed since bootstrapping Flux
    ]
  }
}

resource "github_repository_file" "sync" {
  repository = data.github_repository.main.name
  file       = data.flux_sync.main.path
  content    = data.flux_sync.main.content
  branch     = data.github_repository.main.default_branch
  depends_on = [github_repository_file.install]

  lifecycle {
    ignore_changes = [
      content # Do not overwrite even if content has changed since bootstrapping Flux
    ]
  }
}

resource "github_repository_file" "kustomize" {
  repository = data.github_repository.main.name
  file       = data.flux_sync.main.kustomize_path
  content    = data.flux_sync.main.kustomize_content
  branch     = data.github_repository.main.default_branch
  depends_on = [github_repository_file.sync]

  lifecycle {
    ignore_changes = [
      content # Do not overwrite even if content has changed since bootstrapping Flux
    ]
  }
}
