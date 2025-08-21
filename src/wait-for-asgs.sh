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

echo "Waiting on auto scaling groups instances in $cluster_name"

# Get a list of Auto Scaling Groups with the specified cluster name tag
asg_list=$(aws autoscaling describe-auto-scaling-groups --query "AutoScalingGroups[?not_null(Tags[?Key == 'kubernetes.io/cluster/$cluster_name'].Value)].AutoScalingGroupName" --output text)

# Loop through the Auto Scaling Groups and wait until all their instances are "in service"
for asg in $asg_list; do
  echo "Waiting for $asg to have all instances in service..."
  while [ -n "$(aws autoscaling describe-auto-scaling-groups --auto-scaling-group-names $asg --query "AutoScalingGroups[0].Instances[?LifecycleState!='InService'].InstanceId" --output text)" ]; do
      echo -n "."
    sleep 5
  done
  echo "- $asg now has all instances in service"
done

echo "All instances are in service"
