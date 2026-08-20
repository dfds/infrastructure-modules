# --------------------------------------------------
# AWS auth configmap - default or from Blaster S3 bucket
# --------------------------------------------------

data "aws_s3_buckets" "this" {}

data "aws_s3_objects" "this" {
  for_each = toset([for bucket in data.aws_s3_buckets.this.buckets : bucket if bucket.name == var.blaster_configmap_s3_bucket])
  bucket   = each.key
}

data "aws_s3_object" "this" {
  count  = contains(try(data.aws_s3_objects.this[var.blaster_configmap_s3_bucket].keys, []), var.blaster_configmap_key) && var.blaster_configmap_apply ? 1 : 0
  bucket = data.aws_s3_objects.this[var.blaster_configmap_s3_bucket].id
  key    = var.blaster_configmap_key
}

locals {
  blaster_configmap_s3_bucket_object_exists = contains(try(data.aws_s3_objects.this[var.blaster_configmap_s3_bucket].keys, []), var.blaster_configmap_key)
}

resource "kubernetes_manifest" "enable-workers-default" {
  manifest = local.blaster_configmap_s3_bucket_object_exists ? yamldecode(data.aws_s3_object.this[0].body) : yamldecode(local.default_auth_cm_template)
}
