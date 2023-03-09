output "autoscaling_group_id" {
  # For an auto scaling group the name is the ID.
  value = try(aws_eks_node_group.group[*].resources[*].autoscaling_groups[*].name, [])
}

output "container_runtime" {
  value = var.container_runtime
}

