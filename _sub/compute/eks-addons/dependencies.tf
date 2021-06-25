# Apply specific versions of Kubernetes add-ons depending on EKS version
# Cluster:    https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html
# CNI:        https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
# CoreDNS:    https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
# Kube-proxy: https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html

locals {
  vpccni_version_map = {
    "1.15" = "1.7.5"
    "1.16" = "1.7.5"
    "1.17" = "1.7.5"
    "1.18" = "1.7.5"
    "1.19" = "1.7.5"
    "1.20" = "1.7.10"
  }

  coredns_version_map = {
    "1.15" = "1.6.6"
    "1.16" = "1.6.6"
    "1.17" = "1.6.6"
    "1.18" = "1.7.0"
    "1.19" = "1.8.0"
    "1.20" = "1.8.3"
  }

  kubeproxy_version_map = {
    "1.15" = "1.15.11"
    "1.16" = "1.16.13"
    "1.17" = "1.17.9"
    "1.18" = "1.18.9"
    "1.19" = "1.19.6"
    "1.20" = "1.20.4"
  }
}

# Lookup actual add-on versions
locals {
  vpccni_version      = var.vpccni_version_override == "" ? local.vpccni_version_map[var.cluster_version] : var.vpccni_version_override
  vpccni_minorversion = join(".", slice(split(".", local.vpccni_version), 0, 2))
  coredns_version     = var.coredns_version_override == "" ? local.coredns_version_map[var.cluster_version] : var.coredns_version_override
  kubeproxy_version   = var.kubeproxy_version_override == "" ? local.kubeproxy_version_map[var.cluster_version] : var.kubeproxy_version_override
}

# Get current AWS region
data "aws_region" "current" {}
