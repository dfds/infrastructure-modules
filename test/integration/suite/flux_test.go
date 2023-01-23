package main

import (
	"testing"
	"time"

	fluxmeta "github.com/fluxcd/pkg/apis/meta"
	v1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/runtime/schema"
)

func TestFluxHelmControllerDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertDeployment(t, clientset, "flux-system", "helm-controller", 1)
}

func TestFluxKustomizeControllerDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertDeployment(t, clientset, "flux-system", "kustomize-controller", 1)
}

func TestFluxNotificationControllerDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertDeployment(t, clientset, "flux-system", "notification-controller", 1)
}

func TestFluxSourceControllerDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertDeployment(t, clientset, "flux-system", "source-controller", 1)
}

func TestFluxKustomizationFluxSystemReconciallationSucceeded(t *testing.T) {
	t.Parallel()

	// Trigger reconcillation
	gvr := schema.GroupVersionResource{
		Group:    "kustomize.toolkit.fluxcd.io",
		Version:  "v1beta2",
		Resource: "kustomizations",
	}
	SetK8sAnnotation(t, gvr, "flux-system", "flux-system",
		fluxmeta.ReconcileRequestAnnotation, time.Now().Format(time.RFC3339Nano))

	// Wait for event
	clientset := NewK8sClientSet(t)
	regarding := v1.ObjectReference{Kind: "Kustomization", Name: "flux-system"}
	AssertEvent(t, clientset, "flux-system", "Normal", "ReconciliationSucceeded", regarding, time.Now())
}
