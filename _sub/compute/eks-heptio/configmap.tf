locals {
  kubeconfig = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${var.eks_endpoint}
    certificate-authority-data: ${var.eks_certificate_authority}
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster_name}"
        - "-r"
        - "${var.aws_assume_role_arn}"
KUBECONFIG
}

locals {
  kubeconfig_users = <<KUBECONFIG


apiVersion: v1
clusters:
- cluster:
    server: ${var.eks_endpoint}
    certificate-authority-data: ${var.eks_certificate_authority}
  name: hellman
contexts:
- context:
    cluster: hellman
    user: aws
  name: hellman-aws
current-context: hellman-aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: aws-iam-authenticator
      args:
        - "token"
        - "-i"
        - "${var.cluster_name}"
KUBECONFIG
}

locals {
  config-map-aws-auth = <<CONFIGMAPAWSAUTH


apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-auth
  namespace: kube-system
data:
  mapRoles: |
    - rolearn: ${var.eks_role_arn}
      username: system:node:{{EC2PrivateDNSName}}
      groups:
        - system:bootstrappers
        - system:nodes
CONFIGMAPAWSAUTH
}