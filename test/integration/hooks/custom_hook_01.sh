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

# Check if Grafana namespace exists
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

# Check if ESO is installed
ESO=$(kubectl get helmrelease -n external-secrets -o custom-columns=VERSION:.spec.chart.spec.version --no-headers | wc -l | tr -d ' ')
if [[ ${ESO} -eq 1 ]]; then
	# Find desired helm chart version
	HELMRELEASE=$(grep external_secrets_helm_chart_version terragrunt.hcl | cut -d '"' -f2)
	if [[ "x${HELMRELEASE}x" != "xx" ]]; then
		echo "Applying/Upgrading CRDs for ESO"
		kubectl apply --server-side -f https://raw.githubusercontent.com/external-secrets/external-secrets/refs/tags/v${HELMRELEASE}/deploy/crds/bundle.yaml
	fi
fi

TENANT_NS=$(kubectl get namespace --no-headers | grep -w flux-tenant-test | wc -l | tr -d ' ')
if [[ ${TENANT_NS} -eq 0 ]]; then
	kubectl create namespace flux-tenant-test
fi
