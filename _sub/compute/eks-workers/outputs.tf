output "worker_role" {
  value = aws_iam_role.eks.arn
}

output "worker_role_id" {
  value = aws_iam_role.eks.id
}

output "worker_role_arn" {
  value = aws_iam_role.eks.arn
}

output "iam_instance_profile_name" {
  value = aws_iam_instance_profile.eks.name
}