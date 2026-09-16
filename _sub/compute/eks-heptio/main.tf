# --------------------------------------------------
# Kubeconfig
# --------------------------------------------------

resource "local_file" "kubeconfig_admin" {
  content  = local.kubeconfig_admin_template
  filename = local.temp_kubeconfig_path

  # The path ${var.kubeconfig_path} is OS and user context-depdendent. This causes problems e.g. when executed locally.
  # The path to the config file might be different than in the state, causing Terraform to fail refreshing state for the KUBECONFIG file.
  # The current workaround is to generate the file in a relative but non-expanded path, and move it using a script.

  provisioner "local-exec" {
    command = "bash -c '${path.module}/move_kubeconfig.sh ${local.temp_kubeconfig_path} ${var.kubeconfig_path}'"
  }
}

