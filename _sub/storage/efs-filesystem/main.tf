# EFS File System
resource "aws_efs_file_system" "efs_file_system" {
  performance_mode = var.performance_mode
  tags = {
    Name = var.filesystem_name
  }
}

# EFS Mount Target in each of the subnets in the VPC
resource "aws_efs_mount_target" "alpha" {
  count = length(var.eks_worker_subnet_ids)
  file_system_id = aws_efs_file_system.efs_file_system.id
  subnet_id      = var.eks_worker_subnet_ids[count.index]
  security_groups = tolist([var.securitygroup_id])
}

# # Define a storage class for EFS bound to the EFS volume previously created
resource "kubernetes_storage_class" "efs-storageclass" {
  metadata {
    name = "csi-efs-${var.filesystem_name}"
  }
  storage_provisioner    = "efs.csi.aws.com"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId = "${aws_efs_file_system.efs_file_system.id}"
    directoryPerms = "700"
    basePath = "/dynamic_provisioning"
  }
}
