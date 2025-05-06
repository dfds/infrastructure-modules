output "bucket_name" {
  value = var.bucket_name
}

output "bucket_arn" {
  value = module.velero_storage.arn
}

output "bucket_replication_role_arn" {
  value = try(module.velero_storage.replication_role_arn, "")
}
