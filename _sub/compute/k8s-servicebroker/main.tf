resource "aws_dynamodb_table" "service-broker-table" {
  count          = var.deploy ? 1 : 0
  name           = var.table_name
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

resource "helm_release" "service-catalog" {
  count      = var.deploy ? 1 : 0
  name       = "catalog"
  repository = "servicecatalog"
  namespace  = "catalog"
  chart      = "catalog"
  # depends_on = ["helm_repository.servicecatalog"]
}

resource "null_resource" "wait_for_servicecatalog" {
  count = var.deploy ? 1 : 0

  triggers = {
    build_number = timestamp()
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

  depends_on = [helm_release.service-catalog]
}

resource "helm_release" "service-broker" {
  count        = var.deploy ? 1 : 0
  name         = var.deploy_name
  namespace    = var.namespace
  repository   = var.chart_repo
  chart        = var.chart_name
  version      = var.chart_version
  force_update = "true"

  set {
    name  = "aws.region"
    value = var.aws_region
  }

  set {
    name  = "aws.tablename"
    value = var.table_name
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
    value = var.aws_workload_account_id
  }

  depends_on = [null_resource.wait_for_servicecatalog]
}

resource "null_resource" "annotate_namespace" {
  count = var.deploy ? 1 : 0

  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${pathexpand("~/.kube/config_${var.cluster_name}")} annotate --overwrite ns aws-sb iam.amazonaws.com/permitted='eks-${var.cluster_name}-servicebroker'"
  }

  depends_on = [helm_release.service-broker]
}

