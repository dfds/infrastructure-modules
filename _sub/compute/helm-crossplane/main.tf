locals {
  provider_aws = [for s in var.crossplane_providers : lower(s) if length(try(regex("^crossplane/provider-aws:", s), [])) > 0]
  provider_kubernetes = [for s in var.crossplane_providers : lower(s) if length(try(regex("^crossplane/provider-kubernetes:", s), [])) > 0]
  provider_confluent = [for s in var.crossplane_providers : lower(s) if length(try(regex("^dfdsdk/provider-confluent:", s), [])) > 0]
  template_name = "crossplane"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "crossplane" {
  name          = var.release_name
  chart         = "universal-crossplane"
  repository    = "https://charts.upbound.io/stable"
  version       = var.chart_version
  namespace     = var.namespace
  recreate_pods = var.recreate_pods
  force_update  = var.force_update
  devel         = var.devel
  values = [
    templatefile("${path.module}/values/values.yaml", {
      crossplane_metrics_enabled = var.crossplane_metrics_enabled
  })]

  depends_on = [kubernetes_namespace.namespace]
}


resource "kubernetes_cluster_role_binding" "crossplane-admin" {
  count = length(var.crossplane_admin_service_accounts)

  metadata {
    name = "crossplane-admin-${var.crossplane_admin_service_accounts[count.index].namespace}-${var.crossplane_admin_service_accounts[count.index].serviceaccount}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "crossplane-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.crossplane_admin_service_accounts[count.index].serviceaccount
    namespace = var.crossplane_admin_service_accounts[count.index].namespace
  }

  depends_on = [helm_release.crossplane]
}

resource "kubernetes_cluster_role_binding" "crossplane-edit" {
  count = length(var.crossplane_edit_service_accounts)

  metadata {
    name = "crossplane-edit-${var.crossplane_edit_service_accounts[count.index].namespace}-${var.crossplane_edit_service_accounts[count.index].serviceaccount}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "crossplane-edit"
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.crossplane_edit_service_accounts[count.index].serviceaccount
    namespace = var.crossplane_edit_service_accounts[count.index].namespace
  }

  depends_on = [helm_release.crossplane]
}

resource "kubernetes_cluster_role_binding" "crossplane-view" {
  count = length(var.crossplane_view_service_accounts)

  metadata {
    name = "crossplane-view-${var.crossplane_view_service_accounts[count.index].namespace}-${var.crossplane_view_service_accounts[count.index].serviceaccount}"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "crossplane-view"
  }
  subject {
    kind      = "ServiceAccount"
    name      = var.crossplane_view_service_accounts[count.index].serviceaccount
    namespace = var.crossplane_view_service_accounts[count.index].namespace
  }

  depends_on = [helm_release.crossplane]
}

resource "kubernetes_service" "crossplane" {
  metadata {
    name = helm_release.crossplane.name
    namespace = helm_release.crossplane.namespace

    labels = {
      scrape-service-metrics = "true"
    }

  }
  spec {
    selector = {
      app = local.template_name
      release = helm_release.crossplane.name
    }
    port {
      name = "metrics"
      port        = 8080
      target_port = 8080
      protocol = "TCP"
    }

    type = "ClusterIP"
  }

  depends_on = [helm_release.crossplane]
}

resource "kubernetes_service" "crossplane-rbac" {
  metadata {
    name = "${helm_release.crossplane.name}-rbac-manager"
    namespace = helm_release.crossplane.namespace

    labels = {
      scrape-service-metrics = "true"
    }

  }
  spec {
    selector = {
      app = "${helm_release.crossplane.name}-rbac-manager"
      release = helm_release.crossplane.name
    }
    port {
      name = "metrics"
      port        = 8080
      target_port = 8080
      protocol = "TCP"
    }

    type = "ClusterIP"
  }

  depends_on = [helm_release.crossplane]
}

resource "kubectl_manifest" "aws_provider_controllerconfig" {

  count = length(local.provider_aws) > 0 ? 1 : 0

  yaml_body = <<YAML
apiVersion: pkg.crossplane.io/v1alpha1
kind: ControllerConfig
metadata:
  name: "aws-provider-config"
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.crossplane_aws_iam_role_name}
spec:
  podSecurityContext:
    fsGroup: 2000
YAML

  depends_on = [helm_release.crossplane]

}

resource "kubectl_manifest" "aws_provider" {

  count = length(local.provider_aws) > 0 ? 1 : 0

  yaml_body = <<YAML
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: "${replace(split(":", local.provider_aws[count.index])[0], "/", "-")}"
spec:
  package: "${local.provider_aws[count.index]}"
  controllerConfigRef:
    name: ${kubectl_manifest.aws_provider_controllerconfig[0].name}
YAML

  depends_on = [kubectl_manifest.aws_provider_controllerconfig]

}

resource "time_sleep" "wait_30_seconds_for_aws_provider" {
  count = length(local.provider_aws) > 0 ? 1 : 0

  create_duration = "30s"
  destroy_duration = "30s"

  triggers = {
    kubectl_manifest = kubectl_manifest.aws_provider[0].name
  }

  depends_on = [kubectl_manifest.aws_provider]
}

resource "kubectl_manifest" "aws_provider_config" {

  count = length(local.provider_aws) > 0 ? 1 : 0

  yaml_body = <<YAML
apiVersion: aws.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: default-aws
spec:
  assumeRoleARN: "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.crossplane_role[0].name}"
  credentials:
    source: InjectedIdentity
YAML

  depends_on = [time_sleep.wait_30_seconds_for_aws_provider]

}


resource "aws_iam_role" "crossplane_role" {

  count = length(local.provider_aws) > 0 ? 1 : 0

  name = var.crossplane_aws_iam_role_name

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${trim(var.eks_openid_connect_provider_url, "https://")}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
	"StringLike": {
          "${trim(var.eks_openid_connect_provider_url, "https://")}:aud": "sts.amazonaws.com",
          "${trim(var.eks_openid_connect_provider_url, "https://")}:sub": "system:serviceaccount:${helm_release.crossplane.namespace}:${kubectl_manifest.aws_provider[0].name}-*"
        }
      }
    }
  ]
}
POLICY

  lifecycle {
    create_before_destroy = true
  }

}

resource "aws_iam_role_policy_attachment" "admin-attach" {
  count = length(local.provider_aws) > 0 ? 1 : 0

  role       = aws_iam_role.crossplane_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "kubectl_manifest" "kubernetes_provider_sa" {
  count = length(local.provider_kubernetes) > 0 ? 1 : 0

  yaml_body = <<YAML
apiVersion: v1
kind: ServiceAccount
metadata:
  name: crossplane-provider-kubernetes
  namespace: ${helm_release.crossplane.namespace}
YAML

  depends_on = [helm_release.crossplane]
}

resource "kubectl_manifest" "kubernetes_provider_controllerconfig" {

  count = length(local.provider_kubernetes) > 0 ? 1 : 0

  yaml_body = <<YAML
apiVersion: pkg.crossplane.io/v1alpha1
kind: ControllerConfig
metadata:
  name: kubernetes-provider-config
spec:
  serviceAccountName: ${kubectl_manifest.kubernetes_provider_sa[0].name}
YAML

  depends_on = [kubectl_manifest.kubernetes_provider_sa]

}

resource "kubectl_manifest" "kubernetes_provider" {

  count = length(local.provider_kubernetes) > 0 ? 1 : 0

  yaml_body = <<YAML
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: "${replace(split(":", local.provider_kubernetes[count.index])[0], "/", "-")}"
spec:
  package: "${local.provider_kubernetes[count.index]}"
  controllerConfigRef:
    name: kubernetes-provider-config
YAML

  depends_on = [kubectl_manifest.kubernetes_provider_controllerconfig]

}


resource "time_sleep" "wait_30_seconds_for_kubernetes_provider" {
  count = length(local.provider_kubernetes) > 0 ? 1 : 0

  depends_on = [kubectl_manifest.kubernetes_provider]

  create_duration = "30s"
  destroy_duration = "30s"

  triggers = {
    kubectl_manifest = kubectl_manifest.kubernetes_provider[0].name
  }
}

resource "kubectl_manifest" "kubernetes_provider_config" {

  count = length(local.provider_kubernetes) > 0 ? 1 : 0

  yaml_body = <<YAML
apiVersion: kubernetes.crossplane.io/v1alpha1
kind: ProviderConfig
metadata:
  name: kubernetes-provider
spec:
  credentials:
    source: InjectedIdentity
YAML

  depends_on = [time_sleep.wait_30_seconds_for_kubernetes_provider]

}

resource "kubectl_manifest" "kubernetes_provider_clusterrole_binding" {
  count = length(local.provider_kubernetes) > 0 ? 1 : 0

  yaml_body = <<YAML
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: provider-kubernetes-admin-binding
subjects:
- kind: ServiceAccount
  name: ${kubectl_manifest.kubernetes_provider_sa[0].name}
  namespace: ${helm_release.crossplane.namespace}
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
YAML

  depends_on = [kubectl_manifest.kubernetes_provider_sa]
}

data "aws_caller_identity" "current" {}

resource "kubectl_manifest" "provider_confluent" {

  count = length(local.provider_confluent) > 0 ? 1 : 0

  yaml_body = <<YAML
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: "${replace(split(":", local.provider_confluent[count.index])[0], "/", "-")}"
spec:
  package: "${local.provider_confluent[count.index]}"
YAML
}


resource "time_sleep" "wait_30_seconds_for_provider_confluent" {
  count = length(local.provider_kubernetes) > 0 ? 1 : 0

  depends_on = [kubectl_manifest.provider_confluent]

  create_duration = "30s"
  destroy_duration = "30s"

  triggers = {
    kubectl_manifest = kubectl_manifest.provider_confluent[0].name
  }
}