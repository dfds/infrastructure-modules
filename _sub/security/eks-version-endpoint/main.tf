resource "kubernetes_manifest" "this" {
  manifest = yamldecode(file("${path.module}/system-public-info-viewer.yaml"))
}
