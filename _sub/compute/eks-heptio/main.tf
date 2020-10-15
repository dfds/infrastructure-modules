# --------------------------------------------------
# Kubeconfig
# --------------------------------------------------

resource "local_file" "kubeconfig_admin" {
  content  = data.template_file.kubeconfig_admin.rendered
  filename = local.temp_kubeconfig_path

  # The path ${var.kubeconfig_path} is OS and user context-depdendent. This causes problems e.g. when executed locally.
  # The path to the config file might be different than in the state, causing Terraform to fail refreshing state for the KUBECONFIG file.
  # The current workaround is to generate the file in a relative but non-expanded path, and move it using a script.

  provisioner "local-exec" {
    command = "bash -c '${path.module}/move_kubeconfig.sh ${local.temp_kubeconfig_path} ${var.kubeconfig_path}'"
  }
}

# Hack'ish workaround, until properly supported by Terraform
# Based on https://discuss.hashicorp.com/t/tips-howto-implement-module-depends-on-emulation/2305
# But since no resources in this module has output attributes, nothing will be considered a dependency by Terraform.
# Using the local file as a data source however, means Terraform have to wait for this step, when creating the dependency graph.
data "local_file" "kubeconfig_admin" {
  filename   = var.kubeconfig_path
  depends_on = [local_file.kubeconfig_admin]
}


# --------------------------------------------------
# AWS auth configmap - default or from Blaster S3 bucket
# --------------------------------------------------

resource "kubernetes_config_map" "aws-auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = local.auth_cm_maproles
  }
}