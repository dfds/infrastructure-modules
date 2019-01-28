

# resource "aws_iam_role" "server_node" {
#   name = "eks-${var.cluster_name}-worker"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": { "Service": "ec2.amazonaws.com"},
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# EOF
# }

resource "aws_iam_role_policy" "server_node" {
  name = "eks-${var.cluster_name}-node"
  role = "${var.worker_role_id}" # get from eks-workers

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "arn:aws:iam::${var.workload_account_id}:role/eks-${var.cluster_name}-kiam-server"
    }
    ]
  }
EOF
}

# resource "aws_iam_instance_profile" "server_node" {
#   name = "eks-${var.cluster_name}-worker"
#   role = "${aws_iam_role.server_node.name}"
# }

resource "aws_iam_role" "server_role" {
  name        = "eks-${var.cluster_name}-kiam-server"
  description = "Role the Kiam Server process assumes"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.workload_account_id}:role/eks-${var.cluster_name}-node"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "server_policy" {
  name        = "kiam_server_policy_${var.cluster_name}"
  description = "Policy for the Kiam Server process"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "server_policy_attach" {
  name       = "kiam-server-attachment_${var.cluster_name}"
  roles      = ["${aws_iam_role.server_role.name}"]
  policy_arn = "${aws_iam_policy.server_policy.arn}"
}
