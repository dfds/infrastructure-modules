output "autoscaling_group_id" {
  value = try(aws_autoscaling_group.eks[*].id, [])
}
