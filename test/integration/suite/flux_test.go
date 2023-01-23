package main

import (
	"testing"
	"time"

	v1 "k8s.io/api/core/v1"
)

func TestFluxHelmControllerDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDeployment(t, clientset, "flux-system", "helm-controller", 1)
}

func TestFluxKustomizeControllerDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDeployment(t, clientset, "flux-system", "kustomize-controller", 1)
}

func TestFluxNotificationControllerDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDeployment(t, clientset, "flux-system", "notification-controller", 1)
}

func TestFluxSourceControllerDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDeployment(t, clientset, "flux-system", "source-controller", 1)
}

func TestFluxKustomizationFluxSystemReconciliationSucceeded(t *testing.T) {
	t.Parallel()
	TriggerFluxReconcillation(t, "kustomizations", "flux-system", "flux-system")

	clientset := NewK8sClientSet(t)
	regarding := v1.ObjectReference{Kind: "Kustomization", Name: "flux-system"}

	AssertK8sEvent(t, clientset, "flux-system", "Normal", "ReconciliationSucceeded", regarding, time.Now())

	AssertK8sDeployment(t, clientset, "flux-system", "source-controller", 1)
	AssertK8sDeployment(t, clientset, "flux-system", "helm-controller", 1)
	AssertK8sDeployment(t, clientset, "flux-system", "kustomize-controller", 1)
	AssertK8sDeployment(t, clientset, "flux-system", "notification-controller", 1)
}
