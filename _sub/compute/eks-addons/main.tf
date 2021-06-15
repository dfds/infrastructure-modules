resource "null_resource" "kubeproxy" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.kubeconfig_path} -n kube-system set image daemonset.apps/kube-proxy kube-proxy=602401143452.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/eks/kube-proxy:v${local.kubeproxy_version}-eksbuild.1"
  }

  triggers = {
    kubeproxy_version = local.kubeproxy_version
  }

  depends_on = [local.kubeproxy_version]

}

resource "null_resource" "coredns" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.kubeconfig_path} -n kube-system set image deployment.apps/coredns coredns=602401143452.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/eks/coredns:v${local.coredns_version}-eksbuild.1"
  }

  triggers = {
    coredns_version = local.coredns_version
  }

  depends_on = [null_resource.kubeproxy, local.coredns_version]
}

resource "null_resource" "coredns_clusterrole" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.kubeconfig_path} apply -f ${path.module}/clusterrole.yaml"
  }

  triggers = {
    coredns_version = local.coredns_version
  }

  depends_on = [local.coredns_version]
}

resource "null_resource" "vpccni" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.kubeconfig_path} apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/v${local.vpccni_version}/config/v${local.vpccni_minorversion}/aws-k8s-cni.yaml"
  }

  triggers = {
    vpccni_version = local.vpccni_version
  }

  depends_on = [null_resource.coredns, local.vpccni_version]
}
