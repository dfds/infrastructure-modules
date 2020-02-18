# --------------------------------------------------
# Init
# --------------------------------------------------

provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }

  home = pathexpand("~/.helm_${var.cluster_name}_kiam")
}

# --------------------------------------------------
# AWS
# --------------------------------------------------

resource "aws_iam_role_policy" "server_node" {
  count = var.deploy ? 1 : 0
  name  = "eks-${var.cluster_name}-node"
  role  = var.worker_role_id # get from eks-workers

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sts:AssumeRole"
      ],
      "Resource": "${local.kiam_server_role_arn}"
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
  count       = var.deploy ? 1 : 0
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
        "AWS": "arn:aws:iam::${var.aws_workload_account_id}:role/eks-${var.cluster_name}-node"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "server_policy" {
  count       = var.deploy ? 1 : 0
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
  count      = var.deploy ? 1 : 0
  name       = "kiam-server-attachment_${var.cluster_name}"
  roles      = [aws_iam_role.server_role[0].name]
  policy_arn = aws_iam_policy.server_policy[0].arn
}

# --------------------------------------------------
# Helm
# --------------------------------------------------

resource "null_resource" "repo_init_helm" {
  count = var.deploy ? 1 : 0

  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    command = "helm init --client-only --home ${pathexpand("~/.helm_${var.cluster_name}_kiam")}"
  }

  provisioner "local-exec" {
    command = "helm --home ${pathexpand("~/.helm_${var.cluster_name}_kiam")} repo update"
  }

  provisioner "local-exec" {
    command = <<EOT
        echo "Testing for Tiller"
        count=0
        while [ `kubectl --kubeconfig ${var.kubeconfig_path} -n kube-system get pod -l name=tiller -o go-template --template='{{range .items}}{{range .status.conditions}}{{ if eq .type "Ready" }}{{ .status }} {{end}}{{end}}{{end}}'` != 'True' ]
        do
            if [ $count -gt 15 ]; then
                echo "Failed to get ready Tiller pod."
                exit 1
            fi
            echo "."
            count=$(( $count + 1 ))
            sleep 4
        done

EOT

  }
}

resource "helm_release" "kiam" {
  count     = var.deploy ? 1 : 0
  name      = "kiam"
  namespace = "kube-system"
  chart     = "stable/kiam"
  version   = "2.0.1-rc4"

  # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
  # force an interpolation expression to be interpreted as a list by wrapping it
  # in an extra set of list brackets. That form was supported for compatibility in
  # v0.11, but is no longer supported in Terraform v0.12.
  #
  # If the expression in the following list itself returns a list, remove the
  # brackets to avoid interpretation as a list of lists. If the expression
  # returns a single list item then leave it as-is and remove this TODO comment.
  values = [
    file("kiam_values.yaml"),
  ]

  set {
    name  = "server.roleBaseArn"
    value = "arn:aws:iam::${var.aws_workload_account_id}:role/"
  }

  set {
    name  = "server.assumeRoleArn"
    value = "arn:aws:iam::${var.aws_workload_account_id}:role/eks-${var.cluster_name}-kiam-server"
  }

  depends_on = [null_resource.repo_init_helm]
}

