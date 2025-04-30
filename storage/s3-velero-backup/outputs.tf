output "bucket_name" {
  value = var.bucket_name
}

output "bucket_arn" {
  value = module.velero_storage.arn
}
