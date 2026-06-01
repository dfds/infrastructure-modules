package main

import (
	"fmt"
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/k8s"
)

func TestFluxResourcesReady(t *testing.T) {
	resources := []string{
		"gitrepository",  // ordering matters, must be first
		"kustomizations", // ordering matters, must be second
		"helmchart",
		"helmrepositories",
		"ocirepositories",
		"helmreleases", // ordering matters, must be last
	}

	options := k8s.NewKubectlOptions("", "", "")

	// Reconcile flux-system gitrepository and kustomization to ensure all "mother" resources are up to date
	reconcileAndWait := func(resource string) {
		namespace := "flux-system"
		name := "flux-system"
		err := k8s.RunKubectlE(t, options, "-n", namespace, "annotate", resource, name, fmt.Sprintf("reconcile.fluxcd.io/requestedAt=%s", fmt.Sprintf("%d", time.Now().Unix())), "--overwrite")
		if err != nil {
			t.Fatalf("Failed to trigger flux-system %s reconciliation: %v", resource, err)
		}
		err = k8s.RunKubectlE(t, options, "-n", namespace, "wait", resource, name, "--for=condition=Ready", "--timeout=5m")
		if err != nil {
			t.Fatalf("Failed flux-system %s reconciliation: %v", resource, err)
		}
	}

	reconcileAndWait("gitrepository")
	reconcileAndWait("kustomization")

	// Wait for all flux resources to be ready
	for _, resource := range resources {
		t.Run(resource, func(t *testing.T) {
			if resource != "gitrepository" && resource != "kustomizations" {
				t.Parallel()
			}
			err := k8s.RunKubectlE(t, options, "wait", resource, "--for=condition=Ready", "--all", "-A", "--timeout=5m")
			if err != nil {
				t.Fatalf("%s not ready: %v", resource, err)
			}
		})
	}
}
