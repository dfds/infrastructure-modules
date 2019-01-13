provider "helm" {
  kubernetes {
    config_path = "${pathexpand("~/.kube/config_${var.cluster_name}")}"
  }
}

resource "null_resource" "repo_init_helm" {
  triggers {
    build_number = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "helm init --client-only"
  }

  provisioner "local-exec" {
    command = "helm repo add servicecatalog https://svc-catalog-charts.storage.googleapis.com"
  }

  provisioner "local-exec" {
    command = "helm repo add aws-sb https://awsservicebroker.s3.amazonaws.com/charts"
  }
}

resource "helm_repository" "servicecatalog" {
  triggers {
    build_number = "${timestamp()}"
  }

  name = "servicecatalog"
  url  = "https://svc-catalog-charts.storage.googleapis.com"

  depends_on = [
    "null_resource.repo_init_helm",
  ]
}

resource "helm_repository" "aws-sb" {
  triggers {
    build_number = "${timestamp()}"
  }

  name = "aws-sb"
  url  = "https://awsservicebroker.s3.amazonaws.com/charts"

  depends_on = [
    "null_resource.repo_init_helm",
  ]
}

resource "helm_release" "service-catalog" {
  name       = "catalog"
  repository = "${helm_repository.servicecatalog.metadata.0.name}"
  namespace  = "catalog"
  chart      = "catalog"

  depends_on = ["helm_repository.servicecatalog"]
}

resource "helm_release" "service-broker" {
  name       = "aws-servicebroker"
  repository = "${helm_repository.aws-sb.metadata.0.name}"
  namespace  = "aws-sb"
  chart      = "aws-servicebroker"
  version    = "1.0.0-beta.3"

  set {
    name  = "aws.region"
    value = "${var.aws_region}"
  }

  set {
    name  = "aws.tablename"
    value = "${var.table_name}-${var.cluster_name}"
  }

  set {
    name  = "brokerconfig.brokerid"
    value = "${var.cluster_name}sb"
  }

  set_string {
    name  = "aws.targetaccountid"
    value = "${var.workload_account_id}"
  }

  depends_on = [
    "helm_repository.aws-sb",
    "helm_release.service-catalog"
  ]
}