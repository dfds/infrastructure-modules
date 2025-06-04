# --------------------------------------------------
# Kubeconfig
# --------------------------------------------------

resource "null_resource" "kubeconfig_admin" {
  triggers = {
    content_hash = sha1(local.kubeconfig_admin_template)
  }

  # The path ${var.kubeconfig_path} is OS and user context-dependent. This causes problems e.g. when executed locally.
  # The path to the config file might be different than in the state, causing Terraform to fail refreshing state for the KUBECONFIG file.
  # The current workaround is to generate the file in a relative but non-expanded path, and move it using a script.

  provisioner "local-exec" {
    command = <<EOT
      echo "${local.kubeconfig_admin_template}" > ${local.temp_kubeconfig_path}
      bash -c '${path.module}/move_kubeconfig.sh ${local.temp_kubeconfig_path} ${var.kubeconfig_path}'
    EOT
  }
}



# --------------------------------------------------
# AWS auth configmap - default or from Blaster S3 bucket
# --------------------------------------------------

locals {
  path_default_configmap = "${path.cwd}/default-auth-cm.yaml"
}

resource "null_resource" "apply_default_configmap" {
  count = var.blaster_configmap_apply ? 0 : 1

  triggers = {
    content_hash = sha1(local.default_auth_cm_template)
  }

  provisioner "local-exec" {
    command = <<EOT
      echo '${local.default_auth_cm_template}' > ${local.path_default_configmap}
      kubectl --kubeconfig ${var.kubeconfig_path} apply -f ${local.path_default_configmap}
    EOT
  }

  depends_on = [
    null_resource.kubeconfig_admin
  ]
}


resource "null_resource" "enable-workers-from-s3" {
  count = var.blaster_configmap_apply ? 1 : 0

  # Terraform does not seem to re-run script, unless a trigger is defined
  triggers = {
    timestamp = timestamp()
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/apply_blaster_configmap.sh ${data.aws_region.current.name} ${var.kubeconfig_path} ${var.blaster_configmap_s3_bucket} ${var.blaster_configmap_key} ${local.path_default_configmap} ${var.aws_assume_role_arn}"
    quiet   = true
  }

  depends_on = [
    null_resource.kubeconfig_admin,
    null_resource.apply_default_configmap,
  ]
}
