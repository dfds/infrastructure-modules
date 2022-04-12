locals {
  name      = "confluent-provider"
}

resource "kubernetes_secret" "this" {
  metadata {
    name      = local.name
    namespace = var.namespace
  }

  data = {
    secret = "${var.email}:${var.password}"
  }
}

resource "kubernetes_manifest" "this" {
  manifest = {
    "apiVersion" = "confluent.crossplane.io/v1alpha1"
    "kind"       = "ProviderConfig"
    "metadata" = {
      "name"      = local.name
    }
    "spec" = {
      "credentials" = {
        "source" = "Secret"
        "secretRef" = {
          "name" = local.name
          "namespace" = kubernetes_secret.this.metadata[0].name
          "key" = "secret"
        }
      }
    }
  }
}