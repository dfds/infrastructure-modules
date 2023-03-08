#!/bin/bash

# This script is used to override the /etc/eks/eni-max-pods.txt within
# EKS AMIs using values which take into consideration the utilization of
# prefix delegation feature on the VPC CNI EKS add-on.

CNI_VERSION="1.12.1"

INSTANCE_TYPES=(
    "m5a.12xlarge"
    "m5a.16xlarge"
    "m5a.24xlarge"
    "m5a.2xlarge"
    "m5a.4xlarge"
    "m5a.8xlarge"
    "m5a.large"
    "m5a.xlarge"
    "m6a.12xlarge"
    "m6a.16xlarge"
    "m6a.24xlarge"
    "m6a.2xlarge"
    "m6a.32xlarge"
    "m6a.48xlarge"
    "m6a.4xlarge"
    "m6a.8xlarge"
    "m6a.large"
    "m6a.metal"
    "m6a.xlarge"
    "t3.2xlarge"
    "t3.large"
    "t3.medium"
    "t3.micro"
    "t3.nano"
    "t3.small"
    "t3.xlarge"
    "t3a.2xlarge"
    "t3a.large"
    "t3a.medium"
    "t3a.micro"
    "t3a.nano"
    "t3a.small"
    "t3a.xlarge"
)

for INSTANCE_TYPE in "${INSTANCE_TYPES[@]}"
do
    OUTPUT=$(./max-pods-calculator.sh --instance-type $INSTANCE_TYPE --cni-version $CNI_VERSION --cni-prefix-delegation-enabled)
    echo "$INSTANCE_TYPE $OUTPUT"
done
