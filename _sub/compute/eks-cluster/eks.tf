#tfsec:ignore:aws-cloudwatch-log-group-customer-key
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = var.log_retention_days
}




#tfsec:ignore:aws-eks-no-public-cluster-access-to-cidr tfsec:ignore:aws-eks-no-public-cluster-access tfsec:ignore:aws-eks-encrypt-secrets tfsec:ignore:aws-eks-enable-control-plane-logging
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks.arn
  version  = var.cluster_version

  enabled_cluster_log_types = var.log_types

  vpc_config {
    security_group_ids = var.additional_security_groups
    subnet_ids         = concat(["${var.worker_subnet_ids[0]}"], ["${var.worker_subnet_ids[1]}"])
    endpoint_private_access = true
    endpoint_public_access  = true
  }

## -- EKS Auto Mode
  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
    bootstrap_cluster_creator_admin_permissions = var.migrate_to_eks_automode ? true : false 
  }

  compute_config {
    enabled = true
    node_pools = [
      "general-purpose",
      "system"]
    node_role_arn = aws_iam_role.node.arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  bootstrap_self_managed_addons = var.migrate_to_eks_automode ? true : false 



  depends_on = [
    aws_cloudwatch_log_group.eks,
    aws_iam_role_policy_attachment.cluster,
    aws_iam_role_policy_attachment.service,
    aws_iam_role_policy_attachment.cluster_AmazonEKSComputePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSBlockStoragePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSLoadBalancingPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSNetworkingPolicy,
  ]

  # The AWS API will return OK before the Kubernetes cluster is actually available
  # Wait an arbitrary amount of time for cluster to become ready
  # Workaround for https://github.com/aws/containers-roadmap/issues/654"
  provisioner "local-exec" {
    command = "sleep ${var.sleep_after}"
  }

}
