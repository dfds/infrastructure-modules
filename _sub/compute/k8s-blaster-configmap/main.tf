resource "null_resource" "apply_blaster_configmap" {

  count = "${var.deploy}"

  # Terraform does not seem to re-run script, unless a trigger is defined
  triggers {
    timestamp = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/apply_blaster_configmap.sh ${pathexpand("~/.kube/config_${var.cluster_name}")} ${var.s3_bucket} ${var.configmap_key} ${var.aws_assume_role_arn}"
  }
}
