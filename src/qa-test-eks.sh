#!/bin/bash
set -eux #-o pipefail

BASEPATH=./test/integration
ACTION=$1
# $AWS_DEFAULT_REGION

function extra_cleanup {

    # Remove specific resources that sometimes get left behind (always return true, as resource may have been successfully been cleaned up)
    
    # Delete EKS IAM roles
    aws --no-cli-pager --region "$REGION" iam list-roles --output json | jq -r --arg ROLEPREFIX "eks-${CLUSTERNAME}-" '.Roles[] | select( .RoleName | contains($ROLEPREFIX, "Velero") ) | .RoleName' | xargs -r -L1 aws --no-cli-pager --region "$REGION" iam delete-role --role-name || true

    # Delete network interfaces
    aws --no-cli-pager --region "$REGION" ec2 describe-network-interfaces --filters "Name=group-name,Values=eks-${CLUSTERNAME}-node" --query "NetworkInterfaces[].NetworkInterfaceId" --output text | xargs -r -L1 aws --no-cli-pager --region "$REGION" ec2 delete-network-interface --network-interface-id || true
    
}


if [ "$ACTION" = "init" ]; then
    az login --service-principal --username "$ARM_CLIENT_ID" --password "$ARM_CLIENT_SECRET" --tenant "$ARM_TENANT_ID"
fi


if [ "$ACTION" = "plan-cluster" ]; then
    REGION=$2
    CLUSTERNAME=$3
    WORKDIR="${BASEPATH}/${REGION}/k8s-${CLUSTERNAME}/cluster"
    # Show the plan of what will be applied
    # Can't run plan all, because later stages depend on data from Terraform state (which is empty)
    # terragrunt plan-all --terragrunt-working-dir ./test/integration --terragrunt-source-update --terragrunt-non-interactive -input=false
    terragrunt plan --terragrunt-working-dir "$WORKDIR" --terragrunt-source-update --terragrunt-non-interactive -input=false
fi


if [ "$ACTION" = "cleanup" ]; then
    REGION=$2
    CLUSTERNAME=$3

    # Remove specific resources that sometimes get left behind (always return true, as resource may have been successfully been cleaned up)
    extra_cleanup
fi


if [ "$ACTION" = "apply-shared" ]; then
    SUBPATH=$2
    WORKDIR="${BASEPATH}/${SUBPATH}"
        
    # Apply the configuration
    terragrunt apply-all --terragrunt-working-dir "$WORKDIR" --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
fi


if [ "$ACTION" = "apply-cluster" ]; then
    REGION=$2
    CLUSTERNAME=$3
    WORKDIR="${BASEPATH}/${REGION}/k8s-${CLUSTERNAME}"
        
    # Apply the configuration
    terragrunt apply-all --terragrunt-working-dir "$WORKDIR" --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve
fi


if [ "$ACTION" = "test" ]; then
    # --------------------------------------------------
    # Get kubeconfig path
    # --------------------------------------------------

    REGION=$2
    CLUSTERNAME=$3
    WORKDIR="${BASEPATH}/${REGION}/k8s-${CLUSTERNAME}/cluster"
    export KUBECONFIG=$(terragrunt output kubeconfig_path --terragrunt-working-dir "$WORKDIR")

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

    # Crossplane
    echo -e "\nCrossplane Providers:\n"
    kubectl get provider.pkg || true

    # Traefik Okta
    echo -e "\nTraefik Okta:\n"
    kubectl rollout status -n kube-system deployment traefik-okta || true

    # Atlantis
    echo -e "\nAtlantis:\n"
    kubectl -n atlantis get all || true
    
    # Daemonset exists
    # kubectl --kubeconfig $KUBECONFIG -n fluentd get ds -o name | grep fluentd-cloudwatch
    # if [ $? -ne 0 ]; then
    #     echo "Daemonset 'fluentd-cloudwatch' not found"
    # fi

    # Verify number of available pods?

fi


if [ "$ACTION" = "destroy-cluster" ]; then
    RETURN=0
    REGION=$2
    CLUSTERNAME=$3
    WORKDIR="${BASEPATH}/${REGION}/k8s-${CLUSTERNAME}"

    # Disable cluster logging
    echo Disabling cluster logging
    aws --region "$REGION" eks update-cluster-config --name "$CLUSTERNAME" --logging '{"clusterLogging":[{"types":["api","audit","authenticator","controllerManager","scheduler"],"enabled":false}]}' || true
    sleep 60

    # Essential cleanup commands (set RETURN=1 if fails)
    terragrunt destroy-all --terragrunt-working-dir "$WORKDIR" --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve || RETURN=1
    
    # Remove specific resources that sometimes get left behind (always return true, as resource may have been successfully been cleaned up)
    extra_cleanup

    # Return false, if any *eseential* commands failed
    if [ $RETURN -ne 0 ]; then
        false
    fi
fi


if [ "$ACTION" = "destroy-shared" ]; then
    SUBPATH=$2
    WORKDIR="${BASEPATH}/${SUBPATH}"
    
    # Cleanup
    terragrunt destroy-all --terragrunt-working-dir "$WORKDIR" --terragrunt-source-update --terragrunt-non-interactive -input=false -auto-approve || true
fi
