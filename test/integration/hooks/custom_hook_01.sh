#!/bin/bash

WORKDIR=$(pwd)
PARENT_DIR="${1:-$WORKDIR}"

echo "WORKDIR=$WORKDIR"

echo "PARENT_DIR=$PARENT_DIR"

cd "$PARENT_DIR/eu-west-1/k8s-qa/cluster" || return

echo "Finding KUBECONFIG..."

unset KUBECONFIG
KUBECONFIG=$(terragrunt output --raw kubeconfig_path)
export KUBECONFIG

echo "KUBECONFIG=$KUBECONFIG"

cd "$PARENT_DIR/eu-west-1/k8s-qa/services" || return

MUTE_ME=$(kubectl get crd ingressroutes.traefik.io --output=custom-columns=NAME:.metadata.name --no-headers)

if [[ $? -ne 0 ]]; then
	curl -LO --silent https://github.com/traefik/traefik-helm-chart/releases/download/v23.1.0/traefik.yaml
	if [[ -f "./traefik.yaml" ]]; then
		kubectl apply -f ./traefik.yaml || true
	fi
fi
