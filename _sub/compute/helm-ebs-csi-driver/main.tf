# define IAM policy for the CSI Driver to utilise
resource "aws_iam_policy" "csi_driver_policy" {
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


data "aws_arn" "csi_driver_iam_policy_arn" {
  arn = "${aws_iam_policy.csi_driver_policy_v2plus.arn}"
}

resource "aws_iam_policy" "csi_driver_policy_v2plus" {
  name        = "eks-${var.cluster_name}-csidriver"
  description = "Policy for the EKS CSI Driver v2 and later."

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateSnapshot",
                "ec2:AttachVolume",
                "ec2:DetachVolume",
                "ec2:ModifyVolume",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeInstances",
                "ec2:DescribeSnapshots",
                "ec2:DescribeTags",
                "ec2:DescribeVolumes",
                "ec2:DescribeVolumesModifications"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateTags"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*:*:snapshot/*"
            ],
            "Condition": {
                "StringEquals": {
                    "ec2:CreateAction": [
                        "CreateVolume",
                        "CreateSnapshot"
                    ]
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteTags"
            ],
            "Resource": [
                "arn:aws:ec2:*:*:volume/*",
                "arn:aws:ec2:*:*:snapshot/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateVolume"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "aws:RequestTag/ebs.csi.aws.com/cluster": "true"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateVolume"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "aws:RequestTag/CSIVolumeName": "*"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:CreateVolume"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "aws:RequestTag/kubernetes.io/cluster/*": "owned"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteVolume"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/ebs.csi.aws.com/cluster": "true"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteVolume"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/CSIVolumeName": "*"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteVolume"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/kubernetes.io/cluster/*": "owned"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/CSIVolumeSnapshotName": "*"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteSnapshot"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "ec2:ResourceTag/ebs.csi.aws.com/cluster": "true"
                }
            }
        }
    ]
}
EOF

}


data "tls_certificate" "eks" {
  url = "${var.eks_openid_connect_provider_url}"
}

resource "aws_iam_openid_connect_provider" "default" {
  url = var.eks_openid_connect_provider_url

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [data.tls_certificate.eks.certificates.0.sha1_fingerprint]
}

# define IAM role for the CSI Driver to utilise, including a trust relationship for the KAIM Server role
resource "aws_iam_role" "csi_driver_role" {
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
        "AWS": "${var.kiam_server_role_arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

# link the CSI Driver Policy to the newly defined CSI Driver Role
resource "aws_iam_role_policy_attachment" "csi-policy-attach" {
  role       = aws_iam_role.csi_driver_role.name
  policy_arn = aws_iam_policy.csi_driver_policy.arn
}

# define IAM role for the CSI Driver to utilise, including a trust relationship for the KAIM Server role
resource "aws_iam_role" "csi_driver_v2plus_role" {
  name        = "eks-${var.cluster_name}-csiv2plus"
  description = "Role the EKS CSI Driver process assumes"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_arn.csi_driver_iam_policy_arn.account}:oidc-provider/${trim(var.eks_openid_connect_provider_url,"https://")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "${trim(var.eks_openid_connect_provider_url,"https://")}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
EOF

}


resource "aws_iam_role_policy_attachment" "csiv2-policy-attach" {
  role       = aws_iam_role.csi_driver_v2plus_role.name
  policy_arn = aws_iam_policy.csi_driver_policy_v2plus.arn
}


# helm chart deployment for the CSI driver
resource "helm_release" "aws-ebs-csi-driver" {
  name          = "aws-ebs-csi-driver"
  repository    = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart         = "aws-ebs-csi-driver"
  version       = var.chart_version
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
    role_arn = aws_iam_role.csi_driver_role.arn
  })]

}

# definition for storage classes with the new csi provider specified; the parameters mirror what the current default
# gp2 storage class has
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

}

# change gp2 so it's no longer the default storageclass

locals {
  gp2_is_default = false
}

resource "null_resource" "gp2_removedefault_patch" {

  depends_on = [kubernetes_storage_class.csi-gp2]
  triggers = {
    is_default = local.gp2_is_default
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.kubeconfig_path} patch storageclass gp2 -p '{\"metadata\": {\"annotations\":{\"storageclass.kubernetes.io/is-default-class\":\"${local.gp2_is_default}\"}}}'"
  }

}


resource "null_resource" "annotate_csi_serviceaccount" {

  depends_on = [helm_release.aws-ebs-csi-driver]

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.kubeconfig_path} annotate serviceaccount -n kube-system ebs-csi-controller-sa eks.amazonaws.com/role-arn=arn:aws:iam::${data.aws_arn.csi_driver_iam_policy_arn.account}:role/${aws_iam_role.csi_driver_v2plus_role.name} --overwrite"
  }
}


resource "null_resource" "restart_csi_pods" {

  depends_on = [null_resource.annotate_csi_serviceaccount]

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.kubeconfig_path} delete pods -n kube-system -l app.kubernetes.io/instance=aws-ebs-csi-driver"
  }
}
