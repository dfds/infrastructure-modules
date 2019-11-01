locals {
  temp_kubeconfig_path = "./kube_${var.cluster_name}.config"
}

resource "local_file" "kubeconfig" {
  content  = "${local.kubeconfig}"
  filename = "${local.temp_kubeconfig_path}"

  provisioner "local-exec" {
    command = "bash -c '${path.module}/move_kubeconfig.sh ${local.temp_kubeconfig_path} ${var.kubeconfig_path}'"
  }

}

locals {
  path_default_configmap = "${pathexpand("./.terraform/data/config-map-aws-auth_${var.cluster_name}.yaml")}"
}

resource "local_file" "default-configmap" {
  content  = "${local.config-map-aws-auth}"
  filename = "${local.path_default_configmap}"
}

resource "null_resource" "enable-workers-default" {
  count = "${var.blaster_configmap_apply ? 0 : 1}"

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.kubeconfig_path} apply -f ${local.path_default_configmap}"
  }

  depends_on = ["local_file.kubeconfig", "local_file.default-configmap"]

}

resource "null_resource" "enable-workers-from-s3" {
  count = "${var.blaster_configmap_apply}"

  # Terraform does not seem to re-run script, unless a trigger is defined
  triggers {
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/apply_blaster_configmap.sh ${var.kubeconfig_path} ${var.blaster_configmap_s3_bucket} ${var.blaster_configmap_key} ${local.path_default_configmap} ${var.aws_assume_role_arn}"
  }

  depends_on = ["local_file.kubeconfig", "local_file.default-configmap"]

}
