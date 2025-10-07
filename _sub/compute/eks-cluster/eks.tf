resource "aws_cloudwatch_log_group" "eks" {
  #checkov:skip=CKV_AWS_158: Ensure that CloudWatch Log Group is encrypted by KMS
  #checkov:skip=CKV_AWS_338: Ensure CloudWatch log groups retains logs for at least 1 year
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.log_retention_days
}

#trivy:ignore:AVD-AWS-0038 EKS Clusters should have cluster control plane logging turned on
#trivy:ignore:AVD-AWS-0039 EKS should have the encryption of secrets enabled
#trivy:ignore:AVD-AWS-0040 EKS Clusters should have the public access disabled
#trivy:ignore:AVD-AWS-0041 EKS cluster should not have open CIDR range for public access
resource "aws_eks_cluster" "eks" {
  #checkov:skip=CKV_AWS_37: Ensure Amazon EKS control plane logging is enabled for all log types
  #checkov:skip=CKV_AWS_38: Ensure Amazon EKS public endpoint not accessible to 0.0.0.0/0
  #checkov:skip=CKV_AWS_39: Ensure Amazon EKS public endpoint disabled
  #checkov:skip=CKV_AWS_58: Ensure EKS Cluster has Secrets Encryption Enabled
  name     = var.cluster_name
  role_arn = aws_iam_role.eks.arn
  version  = var.cluster_version

  enabled_cluster_log_types = var.log_types

  vpc_config {
    security_group_ids = [aws_security_group.eks-cluster.id]
    subnet_ids         = slice(aws_subnet.eks[*].id, 0, var.cluster_zones)
  }

  depends_on = [
    aws_cloudwatch_log_group.eks,
    aws_iam_role_policy_attachment.cluster,
    aws_iam_role_policy_attachment.service,
  ]

  # The AWS API will return OK before the Kubernetes cluster is actually available
  # Wait an arbitrary amount of time for cluster to become ready
  # Workaround for https://github.com/aws/containers-roadmap/issues/654"
  provisioner "local-exec" {
    command = "sleep ${var.sleep_after}"
  }

}
