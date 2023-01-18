#!/bin/bash
set -eux #-o pipefail

BASEPATH=./test/integration
ACTION=$1


if [ "$ACTION" = "apply-shared" ]; then
    SUBPATH=$2
    WORKDIR="${BASEPATH}/${SUBPATH}"

    # Apply the configuration
    terragrunt run-all apply --terragrunt-working-dir "$WORKDIR" --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
fi


if [ "$ACTION" = "apply-cluster" ]; then
    REGION=$2
    CLUSTERNAME=$3
    WORKDIR="${BASEPATH}/${REGION}/k8s-${CLUSTERNAME}"

    # Apply the configuration
    terragrunt run-all apply --terragrunt-working-dir "$WORKDIR" --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
fi


if [ "$ACTION" = "test" ]; then
    # Get kubeconfig path
    REGION=$2
    CLUSTERNAME=$3
    WORKDIR="${BASEPATH}/${REGION}/k8s-${CLUSTERNAME}/cluster"
    export KUBECONFIG=$(terragrunt output --raw kubeconfig_path --terragrunt-working-dir "$WORKDIR")

    # Debugging
    go version
    (cd "${BASEPATH}/suite" && exec go env || true)

    # Run test suite
    (cd "${BASEPATH}/suite" && exec go test -v)
fi


if [ "$ACTION" = "destroy-cluster" ]; then
    REGION=$2
    CLUSTERNAME=$3
    WORKDIR="${BASEPATH}/${REGION}/k8s-${CLUSTERNAME}"

    # Destroy resources
    terragrunt destroy-all --terragrunt-working-dir "$WORKDIR" --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
fi


if [ "$ACTION" = "destroy-public-bucket" ]; then
    REGION=$2
    SUBPATH=$3
    WORKDIR="${BASEPATH}/${SUBPATH}"

    # Destroy resources
    terragrunt run-all destroy --terragrunt-working-dir "$WORKDIR" --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
fi

if [ "$ACTION" = "destroy-velero-bucket" ]; then
    RETURN=0
    REGION=$2
    SUBPATH=$3
    WORKDIR="${BASEPATH}/${SUBPATH}"

    # Destroy resources
    terragrunt run-all destroy --terragrunt-working-dir "$WORKDIR" --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
fi
