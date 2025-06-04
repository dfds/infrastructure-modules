output "arn" {
  value = module.shared_symmetric_key.arn
}

output "id" {
  value = module.shared_symmetric_key.key_id
}

output "alias" {
  value = module.shared_symmetric_key.alias
}

output "replica_arn" {
  value = module.shared_symmetric_key.replica_arn
}
