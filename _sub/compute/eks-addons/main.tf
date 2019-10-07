resource "null_resource" "kubeproxy" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.kubeconfig_path} -n kube-system set image daemonset.apps/kube-proxy kube-proxy=602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/kube-proxy:v${local.kubeproxy_version}"
  }

  triggers {
    kubeproxy_version = "${local.kubeproxy_version}"
  }
}

resource "null_resource" "coredns" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.kubeconfig_path} -n kube-system set image deployment.apps/coredns coredns=602401143452.dkr.ecr.us-west-2.amazonaws.com/eks/coredns:v${local.coredns_version}"
  }

  triggers {
    coredns_version = "${local.coredns_version}"
  }

  depends_on = ["null_resource.kubeproxy"]
}

resource "null_resource" "vpccni" {
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.kubeconfig_path} apply -f https://raw.githubusercontent.com/aws/amazon-vpc-cni-k8s/release-${local.vpccni_version}/config/v${local.vpccni_minorversion}/aws-k8s-cni.yaml"
  }

  triggers {
    vpccni_version = "${local.vpccni_version}"
  }

  depends_on = ["null_resource.coredns"]
}
