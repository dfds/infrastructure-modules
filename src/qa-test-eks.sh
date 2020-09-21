#!/bin/bash
set -eu -o pipefail

BASEPATH=./test/integration
ACTION=$1


if [ "$ACTION" = "init" ]; then
    az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
fi


if [ "$ACTION" = "plan" ]; then
    SUBPATH=$2
    WORKDIR="${BASEPATH}/${SUBPATH}"
    # Show the plan of what will be applied
    # Can't run plan all, because later stages depend on data from Terraform state (which is empty)
    # terragrunt plan-all --terragrunt-working-dir ./test/integration --terragrunt-source-update --terragrunt-non-interactive -input=false
    terragrunt plan --terragrunt-working-dir $WORKDIR --terragrunt-source-update --terragrunt-non-interactive -input=false
fi


if [ "$ACTION" = "apply-all" ]; then
    SUBPATH=$2
    WORKDIR="${BASEPATH}/${SUBPATH}"
    # Apply the configuration
    terragrunt apply-all --terragrunt-working-dir $WORKDIR --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
fi


if [ "$ACTION" = "test" ]; then
    echo "Add tests here"
fi

if [ "$ACTION" = "disable-cluster-logging" ]; then
    REGION=$2
    CLUSTERNAME=$3
    aws --region $REGION eks update-cluster-config --name $CLUSTERNAME --logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":false}]}'
    sleep 60
fi

if [ "$ACTION" = "destroy-all" ]; then
    SUBPATH=$2
    CLUSTERNAME=$3
    WORKDIR="${BASEPATH}/${SUBPATH}"
    
    # Cleanup
    terragrunt destroy-all --terragrunt-working-dir $WORKDIR --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
    
    # Remove specific resources that sometimes get left behind
    aws iam delete-role --role-name eks-${CLUSTERNAME}-cluster || true
fi
