# Apply specific versions of Kubernetes add-ons depending on EKS version
# Cluster:    https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html
# CNI:        https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
# CoreDNS:    https://docs.aws.amazon.com/eks/latest/userguide/managing-coredns.html
# Kube-proxy: https://docs.aws.amazon.com/eks/latest/userguide/managing-kube-proxy.html

# Get current default build of an add-on (e.g. 'coredns'):
# aws eks describe-addon-versions --kubernetes-version 1.18 --addon-name coredns | jq -r '.addons[].addonVersions[] | select(.compatibilities[].defaultVersion == true) | .addonVersion'

locals {
  vpccni_version_map = {
    "1.19" = "v1.11.2-eksbuild.1"
    "1.20" = "v1.11.2-eksbuild.1"
    "1.21" = "v1.11.2-eksbuild.1"
    "1.22" = "v1.11.4-eksbuild.1"
    "1.23" = "v1.12.0-eksbuild.1"
    "1.24" = "v1.12.2-eksbuild.1"
    "1.25" = "v1.12.2-eksbuild.1"
  }

  coredns_version_map = {
    "1.19" = "v1.8.0-eksbuild.1"
    "1.20" = "v1.8.3-eksbuild.1"
    "1.21" = "v1.8.4-eksbuild.1"
    "1.22" = "v1.8.7-eksbuild.1"
    "1.23" = "v1.8.7-eksbuild.3"
    "1.24" = "v1.8.7-eksbuild.4"
    "1.25" = "v1.9.3-eksbuild.2"
  }

  kubeproxy_version_map = {
    "1.19" = "v1.19.6-eksbuild.2"
    "1.20" = "v1.20.4-eksbuild.2"
    "1.21" = "v1.21.2-eksbuild.2"
    "1.22" = "v1.22.11-eksbuild.2"
    "1.23" = "v1.23.8-eksbuild.2"
    "1.24" = "v1.24.7-eksbuild.2"
    "1.25" = "v1.25.6-eksbuild.1"
  }

  awsebscsidriver_version_map = {
    "1.22" = "v1.11.4-eksbuild.1"
    "1.23" = "v1.14.0-eksbuild.1"
    "1.24" = "v1.16.1-eksbuild.1"
    "1.25" = "v1.16.1-eksbuild.1"
  }
}

# Lookup actual add-on versions
locals {
  vpccni_version          = var.vpccni_version_override == "" ? local.vpccni_version_map[var.cluster_version] : var.vpccni_version_override
  coredns_version         = var.coredns_version_override == "" ? local.coredns_version_map[var.cluster_version] : var.coredns_version_override
  kubeproxy_version       = var.kubeproxy_version_override == "" ? local.kubeproxy_version_map[var.cluster_version] : var.kubeproxy_version_override
  awsebscsidriver_version = var.awsebscsidriver_version_override == "" ? local.awsebscsidriver_version_map[var.cluster_version] : var.awsebscsidriver_version_override
}
