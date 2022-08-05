data "github_repository" "main" {
  full_name = "${var.github_owner}/${var.repo_name}"
}

locals {
  default_repo_branch                   = data.github_repository.main.default_branch
  repo_branch                           = length(var.repo_branch) > 0 ? var.repo_branch : local.default_repo_branch
  cluster_repo_path                     = "clusters/${var.cluster_name}"
  helm_repo_path                        = "platform-apps/${var.cluster_name}/${var.deploy_name}/helm"
  config_repo_path                      = "platform-apps/${var.cluster_name}/${var.deploy_name}/config"
  app_install_name                      = "platform-apps-${var.deploy_name}"
}

locals {
  app_helm_path = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1beta2"
    "kind" = "Kustomization"
    "metadata" = {
      "name" = "${local.app_install_name}-helm"
      "namespace" = "flux-system"
    }
    "spec" = {
      "interval" = "1m0s"
      "dependsOn" = [
        {
          "name" = "platform-apps-sources"
        }
      ]
      "sourceRef" = {
        "kind" = "GitRepository"
        "name" = "flux-system"
      }
      "path" = "./${local.helm_repo_path}"
      "prune" = true
    }
  }

  app_config_path = {
    "apiVersion" = "kustomize.toolkit.fluxcd.io/v1beta2"
    "kind" = "Kustomization"
    "metadata" = {
      "name" = "${local.app_install_name}-config"
      "namespace" = "flux-system"
    }
    "spec" = {
      "interval" = "1m0s"
      "dependsOn" = [
        {
          "name" = "${local.app_install_name}-helm"
        }
      ]
      "sourceRef" = {
        "kind" = "GitRepository"
        "name" = "flux-system"
      }
      "path" = "./${local.config_repo_path}"
      "prune" = true
    }
  }

  helm_install = {
    "apiVersion" = "kustomize.config.k8s.io/v1beta1"
    "kind"       = "Kustomization"
    "resources" = [
      "https://github.com/dfds/platform-apps/apps/kube-prometheus-stack?ref=users/emcla/main",
      "values.yaml"
    ]
    "patchesStrategicMerge" = [
      "patch.yaml"
    ]
  }

  helm_patch = {
    "apiVersion" = "helm.toolkit.fluxcd.io/v2beta1"
    "kind"       = "HelmRelease"
    "metadata" = {
      "name"      = var.deploy_name
      "namespace" = var.namespace
    }
    "spec" = {
      "valuesFrom" = [
        {
          "kind" = "ConfigMap"
          "name" = "${var.deploy_name}-helm-values"
          "valuesKey" = "components.yaml"
          "optional" = true
        },

        {
          "kind" = "ConfigMap"
          "name" = "${var.deploy_name}-helm-values"
          "valuesKey" = "grafana.yaml"
          "optional" = true
        },

        {
          "kind" = "ConfigMap"
          "name" = "${var.deploy_name}-helm-values"
          "valuesKey" = "grafana_notifiers.yaml"
          "optional" = true
        },

        {
          "kind" = "ConfigMap"
          "name" = "${var.deploy_name}-helm-values"
          "valuesKey" = "prometheus.yaml"
          "optional" = true
        },

        {
          "kind" = "ConfigMap"
          "name" = "${var.deploy_name}-helm-values"
          "valuesKey" = "alertmanager.yaml"
          "optional" = true
        },

        {
          "kind" = "ConfigMap"
          "name" = "${var.deploy_name}-helm-values"
          "valuesKey" = "rules.yaml"
          "optional" = true
        },

        {
          "kind" = "ConfigMap"
          "name" = "${var.deploy_name}-helm-values"
          "valuesKey" = "prometheus_operator.yaml"
          "optional" = true
        },

        {
          "kind" = "ConfigMap"
          "name" = "${var.deploy_name}-helm-values"
          "valuesKey" = "node_exporter.yaml"
          "optional" = true
        },

        {
          "kind" = "ConfigMap"
          "name" = "${var.deploy_name}-helm-values"
          "valuesKey" = "kube_state_metrics.yaml"
          "optional" = true
        },
      ]
      "chart" = {
        "spec" = {
          "version" = var.helm_chart_version
        }
      }
      "values" = {
        "nodeExporter" = {
          "enabled": var.enable_node_exporter
        }
      }
    }
  }

  config_init = {
    "apiVersion" = "kustomize.config.k8s.io/v1beta1"
    "kind" = "Kustomization"
    "resources" = [
#      "ingressroute-dashboard.yaml",
#      "secret-dashboard.yaml",
#      "middleware-dashboard.yaml"
    ]
  }

  yaml_values = [
    templatefile("${path.module}/values/components.yaml", {
    }),

    templatefile("${path.module}/values/grafana.yaml", {
      grafana_admin_password  = var.grafana_admin_password != "" ? var.grafana_admin_password : random_password.grafana_password.result
      grafana_priorityclass   = var.priority_class
      grafana_ingress_path    = var.grafana_ingress_path
      grafana_host            = var.grafana_host
      grafana_root_url        = "https://%(domain)s${var.grafana_ingress_path}"
      grafana_cloudwatch_role = var.grafana_iam_role_arn
      grafana_serviceaccount_name = var.grafana_serviceaccount_name
    }),

    length(var.slack_webhook) > 0 ? templatefile("${path.module}/values/grafana-notifiers.yaml", {
      grafana_notifier_name          = var.grafana_notifier_name
      grafana_slack_notifier_channel = var.slack_channel
      grafana_slack_webhook          = var.slack_webhook
    }) : "",

    templatefile("${path.module}/values/prometheus.yaml", {
      prometheus_priorityclass  = var.priority_class
      prometheus_storageclass   = var.prometheus_storageclass
      prometheus_storage_size   = var.prometheus_storage_size
      prometheus_retention      = var.prometheus_retention
      prometheus_request_memory = var.prometheus_request_memory
      prometheus_request_cpu    = var.prometheus_request_cpu
      prometheus_limit_memory   = var.prometheus_limit_memory
      prometheus_limit_cpu      = var.prometheus_limit_cpu
    }),

    length(var.slack_webhook) > 0 ? templatefile("${path.module}/values/alertmanager-slack.yaml", {
      alertmanager_priorityclass = var.priority_class
      alertmanager_slack_channel = var.slack_channel
      alertmanager_slack_webhook = var.slack_webhook
      target_namespaces          = var.target_namespaces
    }) : file("${path.module}/values/alertmanager-disabled.yaml"),

    templatefile("${path.module}/values/rules.yaml", {
      target_namespaces = var.target_namespaces
    }),

    templatefile("${path.module}/values/prometheus-operator.yaml", {
    }),

    templatefile("${path.module}/values/node-exporter.yaml", {
      prometheus_node_exporter_priorityclass = var.priority_class
    }),

    templatefile("${path.module}/values/kube-state-metrics.yaml", {
      kube_state_metrics_priorityclass = var.priority_class
    })
  ]

  values = templatefile("${path.module}/values/_configMap.yaml", {
    resource_name = "${var.deploy_name}-helm-values"
    resource_namespace = var.namespace

    files = {
      components = templatefile("${path.module}/values/components.yaml", {})

      grafana = templatefile("${path.module}/values/grafana.yaml", {
        grafana_admin_password  = var.grafana_admin_password != "" ? var.grafana_admin_password : random_password.grafana_password.result
        grafana_priorityclass   = var.priority_class
        grafana_ingress_path    = var.grafana_ingress_path
        grafana_host            = var.grafana_host
        grafana_root_url        = "https://%(domain)s${var.grafana_ingress_path}"
        grafana_cloudwatch_role = var.grafana_iam_role_arn
        grafana_serviceaccount_name = var.grafana_serviceaccount_name
      })

      grafana_notifiers =  length(var.slack_webhook) > 0 ? templatefile("${path.module}/values/grafana-notifiers.yaml", {
        grafana_notifier_name          = var.grafana_notifier_name
        grafana_slack_notifier_channel = var.slack_channel
        grafana_slack_webhook          = var.slack_webhook
      }) : ""

      prometheus =     templatefile("${path.module}/values/prometheus.yaml", {
        prometheus_priorityclass  = var.priority_class
        prometheus_storageclass   = var.prometheus_storageclass
        prometheus_storage_size   = var.prometheus_storage_size
        prometheus_retention      = var.prometheus_retention
        prometheus_request_memory = var.prometheus_request_memory
        prometheus_request_cpu    = var.prometheus_request_cpu
        prometheus_limit_memory   = var.prometheus_limit_memory
        prometheus_limit_cpu      = var.prometheus_limit_cpu
      }),

      alertmanager = length(var.slack_webhook) > 0 ? templatefile("${path.module}/values/alertmanager-slack.yaml", {
        alertmanager_priorityclass = var.priority_class
        alertmanager_slack_channel = var.slack_channel
        alertmanager_slack_webhook = var.slack_webhook
        target_namespaces          = var.target_namespaces
      }) : file("${path.module}/values/alertmanager-disabled.yaml")

      rules = templatefile("${path.module}/values/rules.yaml", {
        target_namespaces = var.target_namespaces
      })

      prometheus_operator = templatefile("${path.module}/values/prometheus-operator.yaml", {
      })

      node_exporter = templatefile("${path.module}/values/node-exporter.yaml", {
        prometheus_node_exporter_priorityclass = var.priority_class
      })

      kube_state_metrics = templatefile("${path.module}/values/kube-state-metrics.yaml", {
        kube_state_metrics_priorityclass = var.priority_class
      })
    }
  })
}
