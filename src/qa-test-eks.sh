#!/bin/bash
set -eu -o pipefail

BASEPATH=./test/integration
ACTION=$1
SUBPATH=$2
WORKDIR="${BASEPATH}/${SUBPATH}"


if [ "$ACTION" = "init" ]; then
    helm init --client-only
    helm repo add servicecatalog "https://svc-catalog-charts.storage.googleapis.com"
    helm repo add aws-sb "https://awsservicebroker.s3.amazonaws.com/charts"
    az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
fi


if [ "$ACTION" = "plan" ]; then
    # Show the plan of what will be applied
    # Can't run plan all, because later stages depend on data from Terraform state (which is empty)
    # terragrunt plan-all --terragrunt-working-dir ./test/integration --terragrunt-source-update --terragrunt-non-interactive -input=false
    terragrunt plan --terragrunt-working-dir $WORKDIR --terragrunt-source-update --terragrunt-non-interactive -input=false
fi


if [ "$ACTION" = "apply-all" ]; then
    # Apply the configuration
    terragrunt apply-all --terragrunt-working-dir $WORKDIR --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
fi


if [ "$ACTION" = "test" ]; then
    echo "Add tests here"
fi


if [ "$ACTION" = "destroy-all" ]; then
    # Cleanup
    terragrunt destroy-all --terragrunt-working-dir $WORKDIR --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
fi
