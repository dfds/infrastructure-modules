resource "local_file" "kubeconfig" {
    content = "${local.kubeconfig}"
    filename = "${pathexpand("~/.kube/config")}"
}

resource "local_file" "enable-workers" {

    content = "${local.config-map-aws-auth}"
    filename = "${pathexpand("./.terraform/data/config-map-aws-auth.yaml")}"

    provisioner "local-exec" {
        command = "kubectl apply -f ${pathexpand("./.terraform/data/config-map-aws-auth.yaml")}"
    }

    depends_on = ["local_file.kubeconfig"]

}

