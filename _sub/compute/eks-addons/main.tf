resource "aws_eks_addon" "vpc-cni" {
  cluster_name      = var.cluster_name
  addon_name        = "vpc-cni"
  addon_version     = local.vpccni_version
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "coredns" {
  cluster_name      = var.cluster_name
  addon_name        = "coredns"
  addon_version     = local.coredns_version
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name      = var.cluster_name
  addon_name        = "kube-proxy"
  addon_version     = local.kubeproxy_version
  resolve_conflicts = "OVERWRITE"
}

resource "aws_eks_addon" "aws-ebs-csi-driver" {
  cluster_name      = var.cluster_name
  addon_name        = "aws-ebs-csi-driver"
  addon_version     = local.awsebscsidriver_version
  resolve_conflicts = "OVERWRITE"
}

# Roles & policies
# https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html

data "aws_caller_identity" "this" {
}

locals {
  oidc_issuer = trim(var.eks_openid_connect_provider_url, "https://")
}

data "aws_iam_policy_document" "ebs-csi-driver-assume-role-policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.this.account_id}:oidc-provider/${local.oidc_issuer}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "ebs-csi-driver-role" {
  name        = "eks-${var.cluster_name}-ebs-csi-driver"
  description = "Role the EBS CSI driver assumes"

  assume_role_policy = data.aws_iam_policy_document.ebs-csi-driver-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "managed-ebs-csi-driver-policy" {
  role       = aws_iam_role.ebs-csi-driver-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "kubernetes_annotations" "ebs-csi-driver-role" {
  api_version = "v1"
  kind        = "ServiceAccount"
  force       = "true"

  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
  }

  annotations = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.ebs-csi-driver-role.arn
  }

  depends_on = [
    aws_eks_addon.aws-ebs-csi-driver
  ]
}


# Storage classes

resource "kubernetes_storage_class" "csi-gp2" {
  metadata {
    name = "csi-gp2"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = "true"
  parameters = {
    type = "gp2"
  }

  depends_on = [
    aws_eks_addon.aws-ebs-csi-driver
  ]
}

resource "kubernetes_annotations" "gp2-not-default" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = "true"

  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }

  depends_on = [
    aws_eks_addon.aws-ebs-csi-driver
  ]
}
