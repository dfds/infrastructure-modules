package main

import (
	_ "embed"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
)

// TestVPADeployments verifies that all VPA-related deployments are available.
func TestVPADeployments(t *testing.T) {
	t.Parallel()
	options := k8s.NewKubectlOptions("", "", "vpa")
	k8s.WaitUntilDeploymentAvailableContext(t, t.Context(), options, "vpa-recommender", 60, 5*time.Second)
	k8s.WaitUntilDeploymentAvailableContext(t, t.Context(), options, "vpa-admission-controller", 60, 5*time.Second)
	k8s.WaitUntilDeploymentAvailableContext(t, t.Context(), options, "vpa-updater", 60, 5*time.Second)
}

// TestVPACertificates verifies that all VPA-related certificates are ready and not expired
func TestVPACertificates(t *testing.T) {
	t.Parallel()
	resource := "certificates"
	options := k8s.NewKubectlOptions("", "", "vpa")
	err := k8s.RunKubectlContextE(t, t.Context(), options, "wait", resource, "--for=condition=Ready", "--all", "--timeout=5m")
	if err != nil {
		t.Fatalf("%s not ready: %v", resource, err)
	}
}
