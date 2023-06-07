data "aws_eks_addon_version" "vpc_cni" {
  addon_name         = "vpc-cni"
  kubernetes_version = var.cluster_version
  most_recent        = var.most_recent
}

data "aws_eks_addon_version" "coredns" {
  addon_name         = "coredns"
  kubernetes_version = var.cluster_version
  most_recent        = var.most_recent
}

data "aws_eks_addon_version" "kube_proxy" {
  addon_name         = "kube-proxy"
  kubernetes_version = var.cluster_version
  most_recent        = var.most_recent
}

data "aws_eks_addon_version" "aws_ebs_csi_driver" {
  addon_name         = "aws-ebs-csi-driver"
  kubernetes_version = var.cluster_version
  most_recent        = var.most_recent
}

# Lookup actual add-on versions
locals {
  vpccni_version          = var.vpccni_version_override == "" ? data.aws_eks_addon_version.vpc_cni.version : var.vpccni_version_override
  coredns_version         = var.coredns_version_override == "" ? data.aws_eks_addon_version.coredns.version : var.coredns_version_override
  kubeproxy_version       = var.kubeproxy_version_override == "" ? data.aws_eks_addon_version.kube_proxy.version : var.kubeproxy_version_override
  awsebscsidriver_version = var.awsebscsidriver_version_override == "" ? data.aws_eks_addon_version.aws_ebs_csi_driver.version : var.awsebscsidriver_version_override
}
