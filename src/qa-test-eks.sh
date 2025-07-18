#!/bin/bash
set -eux #-o pipefail

if [[ -z ${TG_TF_PATH+x} ]]; then
	echo "TG_TF_PATH is unset"
else
	echo "TG_TF_PATH is set to ${TG_TF_PATH}"
fi

BASEPATH=./test/integration
ACTION=$1

if [ "$ACTION" = "apply-shared" ]; then
	SUBPATH=$2
	WORKDIR="${BASEPATH}/${SUBPATH}"

	# Apply the configuration
	terragrunt apply --all --working-dir "$WORKDIR" --source-update --non-interactive -input=false -auto-approve
fi

if [ "$ACTION" = "apply-cluster" ]; then
	REGION=$2
	CLUSTERNAME=$3
	WORKDIR="${BASEPATH}/${REGION}/k8s-${CLUSTERNAME}"

	# Apply the configuration
	terragrunt apply --all --working-dir "$WORKDIR" --source-update --non-interactive -input=false -auto-approve
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
	export KUBECONFIG=$(terragrunt output --raw kubeconfig_path --working-dir "$WORKDIR")
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
	terragrunt destroy --all --working-dir "$WORKDIR" --source-update --non-interactive -input=false -auto-approve
fi

if [ "$ACTION" = "destroy-public-bucket" ]; then
	REGION=$2
	SUBPATH=$3
	WORKDIR="${BASEPATH}/${SUBPATH}"

	# Destroy resources
	terragrunt destroy --all --working-dir "$WORKDIR" --source-update --non-interactive -input=false -auto-approve
fi

if [ "$ACTION" = "destroy-velero-bucket" ]; then
	RETURN=0
	REGION=$2
	SUBPATH=$3
	WORKDIR="${BASEPATH}/${SUBPATH}"

	# Destroy resources
	terragrunt destroy --all --working-dir "$WORKDIR" --source-update --non-interactive -input=false -auto-approve
fi
