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

TENANT_NS=$(kubectl get namespace --no-headers | grep -w flux-tenant-test | wc -l | tr -d ' ')
if [[ ${TENANT_NS} -eq 0 ]]; then
	kubectl create namespace flux-tenant-test
fi

cd "${PARENT_DIR}/eu-west-1/k8s-qa/services" || return

C1=$(terragrunt state ls | grep "module.monitoring_namespace.kubernetes_namespace.namespace" | wc -l)

C2=$(terragrunt state ls | grep "module.aws_node_service\[0\].kubernetes_service.this" | wc -l)

C3=$(terragrunt state ls | grep "module.blaster_namespace.kubernetes_namespace.self_service\[0\]" | wc -l)

if [[ ${C1} -gt 0 ]]; then
  echo "Migrating monitoring_namespace.kubernetes_namespace to kubernetes_namespace_v1..."
  terragrunt state show module.monitoring_namespace.kubernetes_namespace.namespace
  terragrunt import module.monitoring_namespace.kubernetes_namespace_v1.namespace monitoring
  terragrunt state rm module.monitoring_namespace.kubernetes_namespace.namespace
fi

if [[ ${C2} -gt 0 ]]; then
  echo "Migrating aws_node_service.kubernetes_service to kubernetes_service_v1..."
  terragrunt state show module.aws_node_service[0].kubernetes_service.this
  terragrunt import module.aws_node_service[0].kubernetes_service_v1.this kube-system/aws-node
  terragrunt state rm module.aws_node_service[0].kubernetes_service.this
fi

if [[ ${C3} -eq 1 ]]; then
  echo "Migrating blaster_namespace.kubernetes_namespace.self_service to kubernetes_namespace_v1..."
  terragrunt state show module.blaster_namespace.kubernetes_namespace.self_service[0]
  terragrunt import module.blaster_namespace.kubernetes_namespace_v1.self_service[0] selfservice
  terragrunt state rm module.blaster_namespace.kubernetes_namespace.self_service[0]
fi
