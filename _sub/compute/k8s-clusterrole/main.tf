resource "kubernetes_cluster_role" "role" {
  metadata {
    name = var.name
  }

  dynamic "rule" {
    for_each = [for r in var.rules: {
      api_groups = r.api_groups
      resources = r.resources
      verbs = r.verbs
    }]

    content {
      api_groups = rule.value.api_groups
      resources = rule.value.resources
      verbs = rule.value.verbs
    }
  }
}

resource "kubernetes_cluster_role_binding" "binding" {
  metadata {
    name = var.name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind = "ClusterRole"
    name = kubernetes_cluster_role.role.metadata.name
  }
  subject {
    api_group = "rbac.authorization.k8s.io"
    name = var.name
    kind = "Group"
  }
}
