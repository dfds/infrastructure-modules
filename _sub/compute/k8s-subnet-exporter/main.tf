resource "aws_iam_role" "this" {
  name                 = local.iam_role_name
  path                 = "/"
  description          = "Role for subnet-exporter to describe ec2 subnets"
  assume_role_policy   = data.aws_iam_policy_document.subnet_exporter_trust.json
  max_session_duration = 3600
}

resource "aws_iam_role_policy" "this" {
  name   = local.iam_role_name
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.subnet_exporter.json
}

resource "kubernetes_service_account" "this" {
  metadata {
    name      = local.serviceaccount_name
    namespace = var.namespace_name
    annotations = {
      "eks.amazonaws.com/role-arn"               = aws_iam_role.this.arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

resource "kubernetes_deployment" "this" {
  metadata {
    name      = local.deployment_name
    namespace = var.namespace_name

    labels = {
      app = local.deployment_name
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = local.deployment_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.deployment_name
        }
      }

      spec {
        service_account_name            = local.serviceaccount_name
        automount_service_account_token = true

        dynamic "toleration" {
          for_each = var.tolerations
          content {
            key      = toleration.value.key
            operator = toleration.value.operator
            value    = toleration.value.value
            effect   = toleration.value.effect
          }
        }

        dynamic "affinity" {
          for_each = length(var.affinity) > 0 ? [var.affinity] : []
          content {
            node_affinity {
              preferred_during_scheduling_ignored_during_execution {
                weight = 1
                preference {
                  dynamic "match_expressions" {
                    for_each = affinity.value
                    content {
                      key      = match_expressions.value.key
                      operator = match_expressions.value.operator
                      values   = match_expressions.value.values
                    }
                  }
                }
              }
            }
          }
        }

        container {
          name  = local.deployment_name
          image = "dfdsdk/aws-subnet-exporter:${var.image_tag}"

          env {
            name  = "REGION"
            value = var.aws_region
          }

          env {
            name  = "FILTER"
            value = "*eks*"
          }

          env {
            name  = "PERIOD"
            value = "30s"
          }

          env {
            name  = "PORT"
            value = ":8080"
          }

          resources {
            requests = {
              cpu = "20m"

              memory = "64Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "this" {
  metadata {
    name      = local.deployment_name
    namespace = var.namespace_name

    labels = {
      app = local.deployment_name

      scrape-service-metrics = "true"
    }
  }

  spec {
    port {
      name        = "metrics"
      protocol    = "TCP"
      port        = 8080
      target_port = "8080"
    }

    selector = {
      app = local.deployment_name
    }
  }
}
