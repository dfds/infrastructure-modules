resource "aws_dynamodb_table" "service-broker-table" {
  count          = "${var.deploy}"
  name           = "${var.table_name}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"
  range_key      = "userid"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "userid"
    type = "S"
  }

  attribute {
    name = "type"
    type = "S"
  }

  global_secondary_index {
    name               = "type-userid-index"
    hash_key           = "type"
    range_key          = "userid"
    write_capacity     = 5
    read_capacity      = 5
    projection_type    = "INCLUDE"
    non_key_attributes = ["id", "userid", "type", "locked"]
  }
}

# resource "null_resource" "repo_init_helm" {
#  count          = "${var.deploy}"
#   triggers {
#     build_number = "${timestamp()}"
#   }

#   provisioner "local-exec" {
#     command = "helm init --client-only"
#   }

#   provisioner "local-exec" {
#     command = "helm repo add servicecatalog https://svc-catalog-charts.storage.googleapis.com"
#   }

#   provisioner "local-exec" {
#     command = "helm repo add aws-sb https://awsservicebroker.s3.amazonaws.com/charts"
#   }

#   provisioner "local-exec" {
#     command = <<EOT
#         echo "Testing for Tiller"
#         count=0
#         kubectl --kubeconfig ${pathexpand("~/.kube/config_${var.cluster_name}")} -n kube-system get pod -l name=tiller -o yaml
#         while [ `kubectl --kubeconfig ${pathexpand("~/.kube/config_${var.cluster_name}")} -n kube-system get pod -l name=tiller -o go-template --template='{{range .items}}{{range .status.conditions}}{{ if eq .type "Ready" }}{{ .status }} {{end}}{{end}}{{end}}'` != 'True' ]
#         do
#             if [ $count -gt 18 ]; then
#                 echo "Failed to get ready Tiller pod."
#                 exit 1
#             fi
#             echo "."
#             count=$(( $count + 1 ))
#             sleep 10
#         done
#         kubectl --kubeconfig ${pathexpand("~/.kube/config_${var.cluster_name}")} -n kube-system get pod -l name=tiller -o yaml
#         sleep 60
#     EOT
#   }
# }

# resource "helm_repository" "servicecatalog" {
#   count          = "${var.deploy}"
#   name = "servicecatalog"
#   url  = "https://svc-catalog-charts.storage.googleapis.com"

#   # depends_on = [
#   #   "null_resource.repo_init_helm",
#   # ]
# }

# resource "helm_repository" "aws-sb" {
#   count          = "${var.deploy}"
#   name = "aws-sb"
#   url  = "https://awsservicebroker.s3.amazonaws.com/charts"

#   # depends_on = [
#   #   "null_resource.repo_init_helm",
#   # ]
# }

resource "helm_release" "service-catalog" {
  count      = "${var.deploy}"
  name       = "catalog"
  repository = "servicecatalog"
  namespace  = "catalog"
  chart      = "catalog"

  # depends_on = ["helm_repository.servicecatalog"]
}

resource "null_resource" "wait_for_servicecatalog" {
  count = "${var.deploy}"

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
          if [ $count -gt 60 ]; then
            echo "Failed to find ClusterServiceBroker definition."
            exit 1
          fi
          sleep 10
        done  
    EOT
  }

  depends_on = ["helm_release.service-catalog"]
}

resource "helm_release" "service-broker" {
  count        = "${var.deploy}"
  name         = "aws-servicebroker"
  repository   = "aws-sb"
  namespace    = "aws-sb"
  chart        = "aws-servicebroker"
  version      = "1.0.0-beta.3"
  force_update = "true"

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

  values = [
    <<EOF
  annotations:
    iam.amazonaws.com/role: "eks-${var.cluster_name}-servicebroker"
  EOF
    ,
  ]

  set_string {
    name  = "aws.targetaccountid"
    value = "${var.aws_workload_account_id}"
  }

  depends_on = [
    # "helm_repository.aws-sb",
    "null_resource.wait_for_servicecatalog",
  ]
}

resource "null_resource" "annotate_namespace" {
  count = "${var.deploy}"

  triggers {
    build_number = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${pathexpand("~/.kube/config_${var.cluster_name}")} annotate --overwrite ns aws-sb iam.amazonaws.com/permitted='eks-${var.cluster_name}-servicebroker'"
  }

  depends_on = ["helm_release.service-broker"]
}
