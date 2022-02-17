# required TLS Certificate which is then used for the openid connect provider thumprint list
data "tls_certificate" "eks" {
  url = "${var.eks_openid_connect_provider_url}"
}

# define openid connect provider that is bound to the provider URL for the EKS cluster
resource "aws_iam_openid_connect_provider" "default" {
  url = var.eks_openid_connect_provider_url

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [data.tls_certificate.eks.certificates.0.sha1_fingerprint]
}
