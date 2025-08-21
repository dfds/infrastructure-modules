#!/bin/bash

# Check if eksctl and aws are installed
command -v aws >/dev/null 2>&1 || { echo >&2 "aws CLI is required but not installed. Aborting."; exit 1; }

# Check if cluster name argument is provided
if [ $# -ne 1 ]; then
  echo "Usage: $0 <cluster-name>"
  exit 1
fi

# Set the cluster name variable
cluster_name=$1

# Get a list of node groups
ng_list=$(aws eks list-nodegroups --cluster-name $cluster_name --query "nodegroups" --output text)

echo "Waiting on node groups in $cluster_name"
for ng in $ng_list; do
  echo "Waiting for $ng to be active..."
  while [ 'ACTIVE' != "$(aws eks describe-nodegroup --cluster-name $cluster_name --nodegroup-name $ng --query "nodegroup.status" --output text)" ]; do
      echo -n "."
    sleep 5
  done
  echo "- $ng is now active"
done

echo "All node groups are active"
