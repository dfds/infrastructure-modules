package main

import (
	_ "embed"
	"fmt"
	"strings"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
	"github.com/gruntwork-io/terratest/modules/random"
	"golang.org/x/mod/semver"
)

//go:embed k8s/karpenter/deployment.yaml
var karpenterTestDeploy string

// karpenterMinVersionForK8s maps a Kubernetes minor version to the minimum
// Karpenter version supported on it.
// Source: https://karpenter.sh/docs/upgrading/compatibility/#compatibility-matrix
var karpenterMinVersionForK8s = map[string]string{
	"v1.36": "v1.13.0",
	"v1.37": "v1.15.0",
}

func TestKarpentersDeployment(t *testing.T) {
	t.Parallel()
	options := k8s.NewKubectlOptions("", "", "karpenter")
	k8s.WaitUntilDeploymentAvailableContext(t, t.Context(), options, "karpenter", 60, 5*time.Second)
}

// TestKarpenterCompatibleWithKubernetesVersion checks that the Karpenter version
// pinned in the OCIRepository is at least the minimum version the compatibility
// matrix requires for the cluster's Kubernetes version.
func TestKarpenterCompatibleWithKubernetesVersion(t *testing.T) {
	t.Parallel()
	options := k8s.NewKubectlOptions("", "", "karpenter")
	client := k8s.GetKubernetesClientContext(t, t.Context())

	serverVersion, err := client.Discovery().ServerVersion()
	if err != nil {
		t.Fatalf("failed to get Kubernetes server version: %v", err)
	}
	k8sMinor := semver.MajorMinor(serverVersion.GitVersion)

	minKarpenter, ok := karpenterMinVersionForK8s[k8sMinor]
	if !ok {
		t.Fatalf("Kubernetes version %s is not found in the Karpenter compatibility matrix; update karpenterMinVersionForK8s with info found here https://karpenter.sh/docs/upgrading/compatibility/#compatibility-matrix", k8sMinor)
	}

	tag, err := k8s.RunKubectlAndGetOutputContextE(t, t.Context(), options, "get", "ocirepositories", "karpenter", "-o", "jsonpath={.spec.ref.tag}")
	if err != nil || tag == "" {
		t.Fatalf("failed to read spec.ref.tag from OCIRepository karpenter: %v", err)
	}

	karpenterVersion := "v" + strings.TrimPrefix(tag, "v")
	if !semver.IsValid(karpenterVersion) {
		t.Fatalf("cannot read a valid semver from OCIRepository tag %q", tag)
	}
	if semver.Compare(karpenterVersion, minKarpenter) < 0 {
		t.Errorf("Karpenter %s is not compatible with Kubernetes %s; minimum required is %s",
			karpenterVersion, k8sMinor, minKarpenter)
	}
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
