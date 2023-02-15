output "autoscaling_group_id" {
  value = try(aws_autoscaling_group.eks[*].id, [])
}

output "container_runtime" {
  value = var.container_runtime
}

