#!/bin/bash

WORKDIR=$(pwd)
PARENT_DIR="${1:-$WORKDIR}"

echo "WORKDIR=${WORKDIR}"

echo "PARENT_DIR=${PARENT_DIR}"

cd "${PARENT_DIR}/eu-west-1/k8s-qa/cluster" || return

echo "Finding KUBECONFIG..."

unset KUBECONFIG
KUBECONFIG=$(terragrunt output --raw kubeconfig_path)
export KUBECONFIG

echo "KUBECONFIG=${KUBECONFIG}"

cd "${PARENT_DIR}/eu-west-1/k8s-qa/services" || return

PVC=$(kubectl get pvc -n grafana --no-headers | wc -l | tr -d ' ')

# Statefulset must be deleted before PVC can be added to it
if [[ ${PVC} -eq 0 ]]; then
	kubectl delete statefulset -n grafana grafana-k8s-monitoring-grafana-agent
fi
