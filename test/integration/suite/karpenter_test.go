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
	k8s.WaitUntilDeploymentAvailable(t, options, "karpenter", 60, 5*time.Second)
}

func TestKarpenterNodes(t *testing.T) {
	t.Parallel()
	namespace := fmt.Sprintf("karpenter-test-%s", strings.ToLower(random.UniqueId()))
	options := k8s.NewKubectlOptions("", "", namespace)
	k8s.CreateNamespace(t, options, namespace)

	defer k8s.DeleteNamespace(t, options, namespace)
	defer k8s.KubectlDeleteFromString(t, options, karpenterTestDeploy)

	k8s.KubectlApplyFromString(t, options, karpenterTestDeploy)
	k8s.WaitUntilDeploymentAvailable(t, options, "karpenter-test", 60, 5*time.Second)
}
