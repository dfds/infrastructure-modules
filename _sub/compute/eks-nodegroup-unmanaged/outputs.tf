output "autoscaling_group_id" {
  value = element(concat(aws_autoscaling_group.eks.*.id, [""]), 0)
}

