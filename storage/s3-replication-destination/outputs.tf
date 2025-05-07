output "bucket_name" {
  value = var.bucket_name
}

output "bucket_arn" {
  value = module.destination.arn
}
