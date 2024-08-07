#!/bin/bash
set -eux #-o pipefail

if [[ -z ${TERRAGRUNT_TFPATH+x} ]]; then
	echo "TERRAGRUNT_TFPATH is unset"
else
	echo "TERRAGRUNT_TFPATH is set to ${TERRAGRUNT_TFPATH}"
fi

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

if [ "$ACTION" = "test-build" ]; then
	TEST_BINARY_PATH=$4

	# Debugging
	go version
	(cd "${BASEPATH}/suite" && exec go env || true)

	# Build test suite
	(cd "${BASEPATH}/suite" && exec go test -c -v -vet=off -o $TEST_BINARY_PATH)
fi

if [ "$ACTION" = "test-run" ]; then
	# Get kubeconfig path
	REGION=$2
	CLUSTERNAME=$3
	WORKDIR="${BASEPATH}/${REGION}/k8s-${CLUSTERNAME}/cluster"
	export KUBECONFIG=$(terragrunt output --raw kubeconfig_path --terragrunt-working-dir "$WORKDIR")
	TEST_BINARY_PATH=$4

	# Make executable
	chmod a+x $TEST_BINARY_PATH

	# Run test suite
	exec $TEST_BINARY_PATH -test.v -test.parallel 30
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
