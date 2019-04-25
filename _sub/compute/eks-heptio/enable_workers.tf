resource "local_file" "kubeconfig" {
  content  = "${local.kubeconfig}"
  filename = "${pathexpand("~/.kube/config_${var.cluster_name}")}"
}

locals {
  path_default_configmap = "${pathexpand("./.terraform/data/config-map-aws-auth_${var.cluster_name}.yaml")}"
}

resource "local_file" "enable-workers-default" {
  count = "${var.blaster_configmap_apply ? 0 : 1}"

  content  = "${local.config-map-aws-auth}"
  filename = "${local.path_default_configmap}"

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${local_file.kubeconfig.filename} apply -f ${local.path_default_configmap}"
  }

  depends_on = ["local_file.kubeconfig"]
}

resource "null_resource" "enable-workers-from-s3" {
  count = "${var.blaster_configmap_apply}"

  # Terraform does not seem to re-run script, unless a trigger is defined
  triggers {
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/apply_blaster_configmap.sh ${pathexpand("~/.kube/config_${var.cluster_name}")} ${var.blaster_configmap_s3_bucket} ${var.blaster_configmap_key} ${local.path_default_configmap} ${var.aws_assume_role_arn}"
  }

  depends_on = ["local_file.kubeconfig"]
}