resource "aws_iam_policy" "csi_driver_policy" {
  #count       = var.deploy ? 1 : 0
  name        = "Amazon_EBS_CSI_Driver_${var.cluster_name}"
  description = "Policy for the EKS CSI Driver process"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AttachVolume",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteSnapshot",
        "ec2:DeleteTags",
        "ec2:DeleteVolume",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DescribeVolumesModifications",
        "ec2:DetachVolume",
        "ec2:ModifyVolume"
      ],
      "Resource": "*"
    }
  ]
}
EOF

}

resource "aws_iam_role" "csi_driver_role" {
  #count       = var.deploy ? 1 : 0
  name        = "eks-${var.cluster_name}-csi"
  description = "Role the EKS CSI Driver process assumes"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.aws_workload_account_id}:role/eks-${var.cluster_name}-kiam-server"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

# Link the CSI Driver Policy to the newly defined CSI Driver Role
resource "aws_iam_role_policy_attachment" "test-attach" {
  role       = aws_iam_role.csi_driver_role.name
  policy_arn = aws_iam_policy.csi_driver_policy.arn
}

# module "kube_system_namespace" {
#   source    = "../k8s-namespace"
#   count     = 1 #var.monitoring_namespace_deploy ? 1 : 0
#   name      = "kube-system"
#   iam_roles = aws_iam_role.csi_driver_role.name
# }

resource "helm_release" "aws-ebs-csi-driver" {
  name          = "aws-ebs-csi-driver"
  chart         = "https://github.com/kubernetes-sigs/aws-ebs-csi-driver/releases/download/v${var.chart_version}/helm-chart.tgz"
  namespace     = "kube-system"
  recreate_pods = true
  force_update  = false

  set {
    name  = "enableVolumeScheduling"
    value = "true"
  }

  set {
    name  = "enableVolumeResizing"
    value = "true"
  }

  set {
    name  = "enableVolumeSnapshot"
    value = "true"
  }

  values = [
    templatefile("${path.module}/values/annotations.yaml", {
      rolename = aws_iam_role.csi_driver_role.name
  })]

}

# definition for storage classes with the new csi provider specified; the parameters mirror what the current default
# gp2 storage class has
resource "kubernetes_storage_class" "csi-gp2" {
  metadata {
    name = "csi-gp2"
  }
  storage_provisioner    = "ebs.csi.aws.com"
  reclaim_policy         = "Delete"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = "false"
  parameters = {
    type = "gp2"
  }

}
