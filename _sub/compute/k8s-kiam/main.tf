# --------------------------------------------------
# AWS
# --------------------------------------------------

resource "aws_iam_role_policy" "server_node" {
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
        "AWS": "arn:aws:iam::${var.aws_workload_account_id}:role/eks-${var.cluster_name}-node"
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
  roles      = [aws_iam_role.server_role.name]
  policy_arn = aws_iam_policy.server_policy.arn
}

# --------------------------------------------------
# Helm
# --------------------------------------------------

resource "helm_release" "kiam" {
  name          = "kiam"
  repository    = "https://uswitch.github.io/kiam-helm-charts/charts"
  namespace     = "kube-system"
  chart         = "kiam"
  version       = var.chart_version
  recreate_pods = var.recreate_pods
  force_update  = var.force_update

  # See: https://github.com/uswitch/kiam/tree/master/helm/kiam

  values = [
    file("kiam_tls.yaml"),
    file("${path.module}/tolerations.yaml")
  ]

  set {
    name  = "agent.allowRouteRegexp"
    value = "(^/latest/meta-data/iam/info$|^/latest/meta-data/instance-id$|^/latest/dynamic/instance-identity/document$|^/latest/meta-data/outpost-arn$)"
  }

  set {
    name  = "agent.deepLivenessProbe"
    value = var.agent_deep_liveness
  }

  set {
    name  = "agent.gatewayTimeoutCreation"
    value = var.agent_gateway_timeout
  }

  set {
    name  = "agent.host.interface"
    value = "eni+"
  }

  set {
    name  = "agent.host.iptables"
    value = "true"
  }

  set {
    name  = "agent.livenessProbe.timeoutSeconds"
    value = var.agent_liveness_timeout
  }

  set {
    name  = "agent.priorityClassName"
    value = var.priority_class
  }

  set {
    name  = "agent.resources.requests.cpu"
    value = var.agent_request_cpu
  }

  set {
    name  = "agent.resources.requests.memory"
    value = var.agent_request_memory
  }

  # set {
  #   name = "agent.podLabels.\"slack\""
  #   value = "dev-excellence"
  # }

  set {
    name  = "server.assumeRoleArn"
    value = "arn:aws:iam::${var.aws_workload_account_id}:role/eks-${var.cluster_name}-kiam-server"
  }

  set {
    name  = "server.gatewayTimeoutCreation"
    value = var.server_gateway_timeout
  }

  set {
    name  = "server.livenessProbe.timeoutSeconds"
    value = var.server_liveness_timeout
  }

  set {
    name  = "server.priorityClassName"
    value = var.priority_class
  }

  set {
    name  = "server.readinessProbe.timeoutSeconds"
    value = var.server_readiness_timeout
  }

  set {
    name  = "server.resources.requests.cpu"
    value = var.server_request_cpu
  }

  set {
    name  = "server.resources.requests.memory"
    value = var.server_request_memory
  }

  set {
    name  = "server.roleBaseArn"
    value = "arn:aws:iam::${var.aws_workload_account_id}:role/"
  }

  set {
    name  = "server.sslCertHostPath"
    value = "/etc/pki/ca-trust/extracted/pem"
  }

  set {
    name  = "server.useHostNetwork"
    value = "true"
  }

  set {
    name = "agent.prometheus.servicemonitor.enabled"
    value = var.servicemonitor_enabled
  }

  set {
    name = "agent.prometheus.servicemonitor.labels.release"
    value = "monitoring"
  }

  set {
    name = "server.prometheus.servicemonitor.enabled"
    value = var.servicemonitor_enabled
  }

  set {
    name = "server.prometheus.servicemonitor.labels.release"
    value = "monitoring"
  }

  set {
    name = "server.extraArgs.disable-strict-namespace-regexp"
    value = "" # Hardcoding for now. Waiting for upstream PR to get approved.
  }
}
