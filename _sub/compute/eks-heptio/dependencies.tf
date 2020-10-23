# --------------------------------------------------
# Kubeconfig
# --------------------------------------------------

locals {
  temp_kubeconfig_path = "./kube_${var.cluster_name}.config"
}

data "template_file" "kubeconfig_admin" {
  template = file("${path.module}/kubeconfig-admin.yaml")
  vars = {
    cluster_name = var.cluster_name
    endpoint     = var.eks_endpoint
    ca           = var.eks_certificate_authority
    role_arn     = var.aws_assume_role_arn
  }
}

data "template_file" "kubeconfig_saml" {
  template = file("${path.module}/kubeconfig-saml.yaml")
  vars = {
    cluster_name = var.cluster_name
    endpoint     = var.eks_endpoint
    ca           = var.eks_certificate_authority
  }
}


# --------------------------------------------------
# AWS auth configmap - default or from Blaster S3 bucket
# --------------------------------------------------

data "template_file" "default_auth_cm" {
  template = file("${path.module}/default-auth-cm.yaml")
  vars = {
    role_arn = var.eks_role_arn
  }
}

# locals {
#   path_default_configmap = "${path.cwd}/default-auth-cm.yaml"
# }

# resource "null_resource" "generate_auth_cm" {
#   # Terraform does not seem to re-run script, unless a trigger is defined
#   triggers = {
#     timestamp = timestamp()
#   }

#   provisioner "local-exec" {
#     command = "bash ${path.module}/generate_auth_cm.sh ${var.blaster_configmap_s3_bucket} ${var.blaster_configmap_key} ${local.path_default_configmap} ${var.aws_assume_role_arn}"
#   }
# }

# data "local_file" "auth_cm" {

#   filename = "${path.cwd}/${var.blaster_configmap_key}"

#   depends_on = [
#     null_resource.generate_auth_cm
#   ]
# }


# locals {
#   # Deserialise auth configmap data, either from Blaster (from S3) or default (local file)
#   auth_cm = yamldecode(data.local_file.auth_cm.content)

#   # Lookup the 'data' attribute of the configmap
#   auth_cm_data = lookup(local.auth_cm, "data", {})

#   # Lookup the 'mapRoles' attribute in 'data'
#   auth_cm_maproles = lookup(local.auth_cm_data, "mapRoles", {})
# }
