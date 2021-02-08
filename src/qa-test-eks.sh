#!/bin/bash
set -eu -o pipefail

BASEPATH=./test/integration
ACTION=$1


if [ "$ACTION" = "init" ]; then
    az login --service-principal --username $ARM_CLIENT_ID --password $ARM_CLIENT_SECRET --tenant $ARM_TENANT_ID
fi


if [ "$ACTION" = "plan" ]; then
    SUBPATH=$2
    WORKDIR="${BASEPATH}/${SUBPATH}"
    # Show the plan of what will be applied
    # Can't run plan all, because later stages depend on data from Terraform state (which is empty)
    # terragrunt plan-all --terragrunt-working-dir ./test/integration --terragrunt-source-update --terragrunt-non-interactive -input=false
    terragrunt plan --terragrunt-working-dir $WORKDIR --terragrunt-source-update --terragrunt-non-interactive -input=false
fi


if [ "$ACTION" = "apply-all" ]; then
    SUBPATH=$2
    WORKDIR="${BASEPATH}/${SUBPATH}"
    # Apply the configuration
    terragrunt apply-all --terragrunt-working-dir $WORKDIR --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
fi


if [ "$ACTION" = "test" ]; then
    # --------------------------------------------------
    # Get kubeconfig path
    # --------------------------------------------------

    SUBPATH=$2
    WORKDIR="${BASEPATH}/${SUBPATH}/cluster"
    export KUBECONFIG=$(terragrunt output kubeconfig_path --terragrunt-working-dir $WORKDIR)

    # Sleep before test?

    # --------------------------------------------------
    # Simply output certain resources for manual inspection
    # --------------------------------------------------

    # KIAM
    echo -e "\nKIAM:\n"
    kubectl -n kube-system get ds -l app=kiam -o wide || true

    # AWS EBS CSI driver
    echo -e "\nAWS EBS CSI snapshot controller statefulset:\n"
    kubectl -n kube-system get statefulset -l app.kubernetes.io/name=aws-ebs-csi-driver -o wide || true
    echo -e "\nAWS EBS CSI controller deloyment:\n"
    kubectl -n kube-system get deployment -l app.kubernetes.io/name=aws-ebs-csi-driver -o wide || true
    echo -e "\nAWS EBS CSI node daemonset:\n"
    kubectl -n kube-system get ds -l app.kubernetes.io/name=aws-ebs-csi-driver || true

    # Flux
    echo -e "\nFlux deployments:\n"
    kubectl -n flux-system get deploy || true

    # FluentD
    echo -e "\nFluentD daemonset:\n"
    kubectl -n fluentd get ds fluentd-cloudwatch || true

    # Daemonset exists
    # kubectl --kubeconfig $KUBECONFIG -n fluentd get ds -o name | grep fluentd-cloudwatch
    # if [ $? -ne 0 ]; then
    #     echo "Daemonset 'fluentd-cloudwatch' not found"
    # fi

    # Verify number of available pods?

fi


if [ "$ACTION" = "disable-cluster-logging" ]; then
    REGION=$2
    CLUSTERNAME=$3
    aws --region $REGION eks update-cluster-config --name $CLUSTERNAME --logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":false}]}' || true
    sleep 60
fi


if [ "$ACTION" = "destroy-cluster" ]; then
    RETURN=0
    SUBPATH=$2
    CLUSTERNAME=$3
    WORKDIR="${BASEPATH}/${SUBPATH}"
    
    # Essential cleanup commands (set RETURN=1 if fails)
    terragrunt destroy-all --terragrunt-working-dir $WORKDIR --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve || RETURN=1
    
    # Remove specific resources that sometimes get left behind (always return true, as resource may have been successfully been cleaned up)
    aws iam delete-role --role-name eks-${CLUSTERNAME}-cluster || true
    aws iam delete-role --role-name eks-${CLUSTERNAME}-node || true
    aws --region eu-west-1 ec2 delete-network-interface --network-interface-id "$(aws --region eu-west-1 ec2 describe-network-interfaces --filters "Name=group-name,Values=eks-${CLUSTERNAME}-node" --query "NetworkInterfaces[].NetworkInterfaceId" --output text)" || true

    # Return false, if any *eseential* commands failed
    if [ $RETURN -ne 0 ]; then
        false
    fi
fi


if [ "$ACTION" = "destroy-shared" ]; then
    SUBPATH=$2
    WORKDIR="${BASEPATH}/${SUBPATH}"
    
    # Cleanup
    terragrunt destroy-all --terragrunt-working-dir $WORKDIR --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve || true
fi
