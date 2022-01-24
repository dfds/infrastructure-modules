output "iam_role_name" {
    value = aws_iam_role.efs_csi_driver_role.name
}

output "securitygroup_id" {
    value = aws_security_group.efs_sg.id
}
