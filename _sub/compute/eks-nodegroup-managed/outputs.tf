output "autoscaling_group_id" {
  value = try(aws_eks_node_group.group.resources[*].autoscaling_groups[*].id, [])
}

output "container_runtime" {
  value = var.container_runtime
}

