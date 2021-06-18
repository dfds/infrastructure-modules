resource "aws_eks_addon" "vpc-cni" {
  cluster_name      = var.cluster_name
  addon_name        = "vpc-cni"
  addon_version     = local.vpccni_version
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "coredns" {
  cluster_name      = var.cluster_name
  addon_name        = "coredns"
  addon_version     = local.coredns_version
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name      = var.cluster_name
  addon_name        = "kube-proxy"
  addon_version     = local.kubeproxy_version
  resolve_conflicts = "OVERWRITE"
}
