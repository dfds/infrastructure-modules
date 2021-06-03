resource "helm_release" "crossplane" {
  name          = var.release_name
  chart         = "crossplane"
  repository    = "https://charts.crossplane.io/stable"
  version       = var.chart_version
  namespace     = var.namespace
  recreate_pods = var.recreate_pods
  force_update  = var.force_update

  values = [
    templatefile("${path.module}/values/values.yaml", {
      crossplane_metrics_enabled = var.crossplane_metrics_enabled
  })]
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}


resource "kubernetes_cluster_role_binding" "crossplane-admin" {
  count = length(var.crossplane_admin_service_accounts)

  metadata {
    name = "crossplane-admin-${var.crossplane_admin_service_accounts[count.index].namespace}-${var.crossplane_admin_service_accounts[count.index].serviceaccount}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "crossplane-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.crossplane_admin_service_accounts[count.index].serviceaccount
    namespace = var.crossplane_admin_service_accounts[count.index].namespace
  }
}

resource "kubernetes_cluster_role_binding" "crossplane-edit" {
  count = length(var.crossplane_edit_service_accounts)

  metadata {
    name = "crossplane-edit-${var.crossplane_edit_service_accounts[count.index].namespace}-${var.crossplane_edit_service_accounts[count.index].serviceaccount}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "crossplane-edit"
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.crossplane_edit_service_accounts[count.index].serviceaccount
    namespace = var.crossplane_edit_service_accounts[count.index].namespace
  }
}

resource "kubernetes_cluster_role_binding" "crossplane-view" {
  count = length(var.crossplane_view_service_accounts)

  metadata {
    name = "crossplane-view-${var.crossplane_view_service_accounts[count.index].namespace}-${var.crossplane_view_service_accounts[count.index].serviceaccount}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "crossplane-view"
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.crossplane_view_service_accounts[count.index].serviceaccount
    namespace = var.crossplane_view_service_accounts[count.index].namespace
  }
}

resource "kubernetes_service" "crossplane" {
  metadata {
    name = helm_release.crossplane.name
    namespace = helm_release.crossplane.namespace

    labels = {
      scrape-service-metrics = "true"
    }

  }
  spec {
    selector = {
      app = helm_release.crossplane.name
      release = helm_release.crossplane.name
    }
    port {
      name = "metrics"
      port        = 8080
      target_port = 8080
      protocol = "TCP"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "crossplane-rbac" {
  metadata {
    name = "${helm_release.crossplane.name}-rbac-manager"
    namespace = helm_release.crossplane.namespace

    labels = {
      scrape-service-metrics = "true"
    }

  }
  spec {
    selector = {
      app = "${helm_release.crossplane.name}-rbac-manager"
      release = helm_release.crossplane.name
    }
    port {
      name = "metrics"
      port        = 8080
      target_port = 8080
      protocol = "TCP"
    }

    type = "ClusterIP"
  }
}

resource "kubectl_manifest" "aws_provider" {

  count = length(var.crossplane_providers)

  yaml_body = <<YAML
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: "${replace(split(":", var.crossplane_providers[count.index])[0], "/", "-")}"
spec:
  package: "${var.crossplane_providers[count.index]}"
YAML

  depends_on = [helm_release.crossplane]

}