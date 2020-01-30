# Apply specific versions of Kubernetes add-ons depending on EKS version
# https://docs.aws.amazon.com/eks/latest/userguide/update-cluster.html 

locals {
  kubeproxy_version_map = "${map(
    "1.13", "1.13.12",
    "1.14", "1.14.9"
  )}"
  coredns_version_map = "${map(
    "1.13", "1.6.6",
    "1.14", "1.6.6"
  )}"
  vpccni_version_map = "${map(
    "1.13", "1.5.5",
    "1.14", "1.5.5"
  )}"
}


# Lookup actual add-on versions
locals {
  kubeproxy_version   = "${var.kubeproxy_version_override == "" ? local.kubeproxy_version_map[var.cluster_version] : var.kubeproxy_version_override}"
  coredns_version     = "${var.coredns_version_override == "" ? local.coredns_version_map[var.cluster_version] : var.coredns_version_override}"
  vpccni_version      = "${var.vpccni_version_override == "" ? local.vpccni_version_map[var.cluster_version] : var.vpccni_version_override}"
  vpccni_minorversion = "${join(".", slice(split(".", local.vpccni_version), 0, 2))}"

}
