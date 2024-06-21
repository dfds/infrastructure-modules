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

# Check if namespace exists
NS=$(kubectl get namespace --no-headers | grep -w grafana | wc -l | tr -d ' ')
if [[ ${NS} -eq 1 ]]; then
	PVC=$(kubectl get pvc -n grafana --no-headers | wc -l | tr -d ' ')
	# Statefulset must be deleted before PVC can be added to it
	if [[ ${PVC} -eq 0 ]]; then
		# Check if statefulset exists
		STATEFULSET=$(kubectl get statefulset grafana-k8s-monitoring-grafana-agent-n grafana --no-headers | wc -l | tr -d ' ')
		if [[ ${STATEFULSET} -eq 1 ]]; then
			kubectl delete statefulset -n grafana grafana-k8s-monitoring-grafana-agent
		fi
	fi
fi
