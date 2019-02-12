provider "helm" {
  kubernetes {
    config_path = "${pathexpand("~/.kube/config_${var.cluster_name}")}"
  }

  home = "${pathexpand("~/.helm_${var.cluster_name}_kiam")}"
}

resource "null_resource" "repo_init_helm" {
  triggers {
    build_number = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "helm init --client-only --home ${pathexpand("~/.helm_${var.cluster_name}_kiam")}"
  }

  provisioner "local-exec" {
    command = "helm --home ${pathexpand("~/.helm_${var.cluster_name}_kiam")} repo update"
  }

  provisioner "local-exec" {
    command = <<EOT
        echo "Testing for Tiller"
        count=0
        kubectl --kubeconfig ${pathexpand("~/.kube/config_${var.cluster_name}")} -n kube-system get pod -l name=tiller -o yaml
        while [ `kubectl --kubeconfig ${pathexpand("~/.kube/config_${var.cluster_name}")} -n kube-system get pod -l name=tiller -o go-template --template='{{range .items}}{{range .status.conditions}}{{ if eq .type "Ready" }}{{ .status }} {{end}}{{end}}{{end}}'` != 'True' ]
        do
            if [ $count -gt 15 ]; then
                echo "Failed to get ready Tiller pod."
                exit 1
            fi
            echo "."
            count=$(( $count + 1 ))
            sleep 4
        done
        kubectl --kubeconfig ${pathexpand("~/.kube/config_${var.cluster_name}")} -n kube-system get pod -l name=tiller -o yaml
    EOT
  }
}

resource "helm_release" "kiam" {
  name      = "kiam"
  namespace = "kube-system"
  chart     = "stable/kiam"
  version   = "2.0.1-rc4"

  values = [
    "${file("kiam_values.yaml")}"
  ]

  set {
    name = "server.roleBaseArn"
    value = "arn:aws:iam::${var.aws_workload_account_id}:role/"
  }

  set {
    name = "server.assumeRoleArn"
    value = "arn:aws:iam::${var.aws_workload_account_id}:role/eks-${var.cluster_name}-kiam-server"
  }

  depends_on = [
    "null_resource.repo_init_helm",
  ]
}