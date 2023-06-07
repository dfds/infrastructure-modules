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

echo "This hook can be used for new purposes"
