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

data "aws_s3_bucket_objects" "auth" {
  count = var.blaster_configmap_apply ? 1 : 0
  bucket = var.blaster_configmap_s3_bucket
  prefix = var.blaster_configmap_key
}

data "aws_s3_bucket_object" "auth" {
  count = try(contains(data.aws_s3_bucket_objects.auth[0].keys, var.blaster_configmap_key), false) ? 1 : 0

  bucket = var.blaster_configmap_s3_bucket
  key    = var.blaster_configmap_key
}

locals {
  # Apply auth configmap from bucket, if feature-toggled on AND configmap file was found in S3
  use_bucket_cm = var.blaster_configmap_apply ? contains(data.aws_s3_bucket_objects.auth[0].keys, var.blaster_configmap_key) : false

  # Deserialise auth configmap data, either from Blaster (from S3) or default (local file)
  auth_cm = local.use_bucket_cm ? yamldecode(data.aws_s3_bucket_object.auth[0].body) : yamldecode(data.template_file.default_auth_cm.rendered)

  # Lookup the 'data' attribute of the configmap
  auth_cm_data = lookup(local.auth_cm, "data", {})

  # Lookup the 'mapRoles' attribute in 'data'
  auth_cm_maproles = lookup(local.auth_cm_data, "mapRoles", {})
}
