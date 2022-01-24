# IAM Policy ARN instance so we can pull specific information from it later
data "aws_arn" "efs_csi_driver_iam_policy_arn" {
  arn = "${aws_iam_policy.efs_csi_driver_policy.arn}"
}

# define IAM policy for the CSI Driver to utilise
#tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_policy" "efs_csi_driver_policy" {
  name        = "eks-${var.cluster_name}-efs-csi-driver"
  description = "Policy for the EFS CSI Driver."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:DescribeAccessPoints",
        "elasticfilesystem:DescribeFileSystems"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticfilesystem:CreateAccessPoint"
      ],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:RequestTag/efs.csi.aws.com/cluster": "true"
        }
      }
    },
    {
      "Effect": "Allow",
      "Action": "elasticfilesystem:DeleteAccessPoint",
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/efs.csi.aws.com/cluster": "true"
        }
      }
    }
  ]
}
EOF

}

# define IAM role for the EFS CSI Driver to utilise, including a trust relationship for the KAIM Server role
resource "aws_iam_role" "efs_csi_driver_role" {
  name        = "eks-${var.cluster_name}-csi-efs"
  description = "Role the EFS CSI Driver process assumes"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_arn.efs_csi_driver_iam_policy_arn.account}:oidc-provider/${trim(var.eks_openid_connect_provider_url,"https://")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${trim(var.eks_openid_connect_provider_url,"https://")}:sub": "system:serviceaccount:kube-system:efs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF

}

# bind policy to the IAM role for the CSI Driver
resource "aws_iam_role_policy_attachment" "csi-policy-attach" {
  role       = aws_iam_role.efs_csi_driver_role.name
  policy_arn = aws_iam_policy.efs_csi_driver_policy.arn
}


# helm chart deployment for the CSI driver
resource "helm_release" "aws-efs-csi-driver" {
  name          = "aws-efs-csi-driver"
  repository    = "https://kubernetes-sigs.github.io/aws-efs-csi-driver"
  chart         = "aws-efs-csi-driver"
  version       = var.chart_version
  namespace     = "kube-system"
  recreate_pods = true
  force_update  = false

  set {
    name = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::${data.aws_arn.efs_csi_driver_iam_policy_arn.account}:role/${aws_iam_role.efs_csi_driver_role.name}"
  }
}


# EFS Security Group; this is used by all mount targets
resource "aws_security_group" "efs_sg" {
  name        = "EFS Security Group"
  description = "Security Group for EFS"
  vpc_id      = var.eks_cluster_vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
}
