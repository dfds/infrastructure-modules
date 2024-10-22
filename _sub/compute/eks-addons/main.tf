resource "aws_eks_addon" "vpc-cni" {
  cluster_name  = var.cluster_name
  addon_name    = "vpc-cni"
  addon_version = local.vpccni_version
  configuration_values = jsonencode({
    "env" = {
      "ENABLE_PREFIX_DELEGATION" = tostring(var.vpccni_prefix_delegation_enabled)
    }
  })
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "coredns" {
  cluster_name                = var.cluster_name
  addon_name                  = "coredns"
  addon_version               = local.coredns_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "kube-proxy" {
  cluster_name                = var.cluster_name
  addon_name                  = "kube-proxy"
  addon_version               = local.kubeproxy_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
}

resource "aws_eks_addon" "aws-ebs-csi-driver" {
  cluster_name                = var.cluster_name
  addon_name                  = "aws-ebs-csi-driver"
  addon_version               = local.awsebscsidriver_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn    = aws_iam_role.ebs-csi-driver-role.arn

  depends_on = [
    aws_iam_role_policy_attachment.managed-ebs-csi-driver-policy
  ]
}

resource "aws_eks_addon" "aws-efs-csi-driver" {
  cluster_name = var.cluster_name
  addon_name   = "aws-efs-csi-driver"
  addon_version = local.awsefscsidriver_version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  service_account_role_arn = aws_iam_role.efs-csi-driver-role.arn

  depends_on = [
    aws_iam_role_policy_attachment.managed-efs-csi-driver-policy
  ]
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

### AWS EFS CSI driver
data "aws_iam_policy_document" "efs-csi-driver-assume-role-policy" {
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
      values   = ["system:serviceaccount:kube-system:efs-csi-controller-sa"]
    }
  }
}

resource "aws_iam_role" "efs-csi-driver-role" {
  name        = "eks-${var.cluster_name}-efs-csi-driver"
  description = "Role the EFS CSI driver assumes"

  assume_role_policy = data.aws_iam_policy_document.efs-csi-driver-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "managed-efs-csi-driver-policy" {
  role       = aws_iam_role.efs-csi-driver-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}

# Storage classes

resource "kubernetes_storage_class" "csi-gp2" {
  metadata {
    name = "csi-gp2"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "false"
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

resource "kubernetes_storage_class" "csi-gp3" {
  metadata {
    name = "csi-gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = "true"
  parameters = {
    type = "gp3"
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

resource "kubernetes_storage_class" "csi-efs" {
  metadata {
    name = "csi-efs"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "false"
    }
  }
  storage_provisioner    = "efs.csi.aws.com"
  reclaim_policy         = "Delete" # ?
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = "false"
  parameters = {
    provisioningMode = "efs-ap"
    fileSystemId = var.efs_fs_id
    directoryPerms = "700"
    gidRangeStart =  "1000"
    gidRangeEnd = "2000"
    basePath = "/namespaces"
    subPathPattern = "$${.PVC.namespace}/$${.PVC.name}"
    ensureUniqueDirectory =  "true"
    reuseAccessPoint = "false" # optional
  }
  depends_on = [
    aws_eks_addon.aws-efs-csi-driver
  ]
}