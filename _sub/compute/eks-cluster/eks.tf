#tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.log_retention_days
}

#tfsec:ignore:aws-eks-no-public-cluster-access-to-cidr tfsec:ignore:aws-eks-no-public-cluster-access tfsec:ignore:aws-eks-encrypt-secrets
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks.arn
  version  = var.cluster_version

  enabled_cluster_log_types = var.log_types

  vpc_config {
    security_group_ids = [aws_security_group.eks-cluster.id]
    subnet_ids         = aws_subnet.eks.*.id
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

# --------------------------------------------------
# AWS IAM Open ID Connect Provider
# --------------------------------------------------
# required TLS Certificate which is then used for the openid connect provider thumprint list
data "tls_certificate" "eks" {
  url = "${aws_eks_cluster.eks.identity[0].oidc[0].issuer}"
}

# define openid connect provider that is bound to the provider URL for the EKS cluster
resource "aws_iam_openid_connect_provider" "default" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [data.tls_certificate.eks.certificates.0.sha1_fingerprint]

  tags = {
    "Name" = "eks-${var.cluster_name}"
  }
}
