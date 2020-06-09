output "autoscaling_group_id" {
  # value = [for asg in aws_autoscaling_group.eks : asg.id]
  value = try(aws_autoscaling_group.eks.*.id, [])
}

