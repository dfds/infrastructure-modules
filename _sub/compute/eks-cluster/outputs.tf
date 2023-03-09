output "autoscale_security_group" {
  value = aws_security_group.eks-cluster.id
}

output "vpc_id" {
  value = aws_vpc.eks.id
}

output "subnet_ids" {
  value = aws_subnet.eks[*].id
}

output "eks_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "eks_certificate_authority" {
  value = aws_eks_cluster.eks.certificate_authority[0].data
}

output "eks_role_arn" {
  value = aws_iam_role.eks.arn
}

output "eks_openid_connect_provider_url" {
  value = aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

