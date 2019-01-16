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
    command = <<EOT
        echo "Testing for Tiller"
        count=0
        while [ `kubectl --kubeconfig ${pathexpand("~/.kube/config_${var.cluster_name}")} -n kube-system get pod -l name=tiller -o go-template --template "{{range .items}}{{.status.phase}}{{end}}"` != "Running" ]
        do
            if [ $count -gt 15 ]; then
                echo "Failed to get ready Tiller pod."
                exit 1
            fi
            echo -n "."
            count=$(( $count + 1 ))
            sleep 3
        done
    EOT
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
  name = "servicecatalog"
  url  = "https://svc-catalog-charts.storage.googleapis.com"

  depends_on = [
    "null_resource.repo_init_helm",
    
  ]
}

resource "helm_repository" "aws-sb" {
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

resource "null_resource" "wait_for_servicecatalog" {
   triggers {
    build_number = "${timestamp()}"
  }
  provisioner "local-exec" {
    command = <<EOT
        echo "Testing for ClusterServiceBroker definition"
        count=0
        exitStatus=99
        echo 
        while [ $exitStatus != 0 ]
        do
          kubectl --kubeconfig ${pathexpand("~/.kube/config_${var.cluster_name}")} get clusterservicebroker
          exitStatus=$?
          echo -n ""
          count=$(( $count + 1 ))
          if [ $count -gt 5 ]; then
            echo "Failed to find ClusterServiceBroker definition."
            exit 1
          fi
          sleep 1
        done  
    EOT
  }

  depends_on = ["helm_release.service-catalog"]

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
    "null_resource.wait_for_servicecatalog"
  ]
}