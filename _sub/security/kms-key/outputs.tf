output "arn" {
  value = aws_kms_key.this.arn
}

output "key_id" {
  value = aws_kms_key.this.key_id
}

output "alias" {
  value = aws_kms_alias.this.name
}

output "replica_arn" {
  value = try(aws_kms_replica_key.this[0].arn, "No replica key created")
}
