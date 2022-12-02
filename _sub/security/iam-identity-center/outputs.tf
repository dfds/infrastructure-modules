output "arn" {
  value = tolist(data.aws_ssoadmin_instances.dfds.arns)[0]
}

output "identity_store_id" {
  value = tolist(data.aws_ssoadmin_instances.dfds.identity_store_ids)[0]
}