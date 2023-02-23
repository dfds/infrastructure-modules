resource "aws_iam_role" "eks" {
  name = "eks-${var.cluster_name}-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks.name
}

resource "aws_iam_role_policy_attachment" "cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks.name
}

resource "aws_iam_instance_profile" "eks" {
  name = "eks-${var.cluster_name}"
  role = aws_iam_role.eks.name
}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "cloudwatch-agent-config-bucket" {
  name = "eks-${var.cluster_name}-cl-agent-config-bucket"
  role = aws_iam_role.eks.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
          "s3:PutAccountPublicAccessBlock",
          "s3:GetAccountPublicAccessBlock",
          "s3:ListAllMyBuckets",
          "s3:HeadBucket"
      ],
      "Resource": "*"
    },
    {
      "Sid": "VisualEditor1",
      "Effect": "Allow",
      "Action": "s3:*",
      "Resource": [
          "arn:aws:s3:::${var.cloudwatch_agent_config_bucket}/*",
          "arn:aws:s3:::${var.cloudwatch_agent_config_bucket}"
      ]
    }
  ]
}
EOF

}

# tfsec:ignore:aws-iam-no-policy-wildcards
resource "aws_iam_role_policy" "cloudwatch_agent_metrics" {
  name = "cloudwatch_agent_metrics"
  role = aws_iam_role.eks.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:Describe*",
        "cloudwatch:PutMetricData",
        "cloudwatch:GetMetricStatistics",
        "cloudwatch:ListMetrics"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF

}


resource "aws_iam_role_policy" "cur" {
  count = var.cur_bucket_arn != null ? 1 : 0
  name  = "eks-${var.cluster_name}-cur-bucket"
  role  = aws_iam_role.eks.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "${var.cur_bucket_arn}",
            "Condition": {
                "StringEquals": {
                    "s3:delimiter": "/"
                },
                "StringLike": {
                    "s3:prefix": "k8s/prometheus*"
                }
            }
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": "${var.cur_bucket_arn}/k8s/prometheus/*"
        }
    ]
}
EOF

}
