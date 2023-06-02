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

kubectl apply --server-side --force-conflicts -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side --force-conflicts -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side --force-conflicts -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side --force-conflicts -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side --force-conflicts -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side --force-conflicts -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side --force-conflicts -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side --force-conflicts -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side --force-conflicts -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side --force-conflicts -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.65.1/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
