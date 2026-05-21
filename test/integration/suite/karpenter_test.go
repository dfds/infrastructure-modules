package main

import (
	_ "embed"
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
)

//go:embed k8s/karpenter/deployment.yaml
var karpenterTestDeploy string

func TestKarpentersDeployment(t *testing.T) {
	t.Parallel()
	options := k8s.NewKubectlOptions("", "", "karpenter")
	k8s.WaitUntilDeploymentAvailableContext(t, t.Context(), options, "karpenter", 60, 5*time.Second)
}

func TestKarpenterNodes(t *testing.T) {
	t.Parallel()
	namespace := fmt.Sprintf("karpenter-test-%s", strings.ToLower(random.UniqueId()))
	options := k8s.NewKubectlOptions("", "", namespace)
	k8s.CreateNamespaceContext(t, t.Context(), options, namespace)

	defer k8s.DeleteNamespaceContext(t, t.Context(), options, namespace)
	defer k8s.KubectlDeleteFromStringContext(t, t.Context(), options, karpenterTestDeploy)

	k8s.KubectlApplyFromStringContext(t, t.Context(), options, karpenterTestDeploy)
	k8s.WaitUntilDeploymentAvailableContext(t, t.Context(), options, "karpenter-test", 60, 5*time.Second)
}
