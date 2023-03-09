package main

import (
	"testing"
)

func TestFluxHelmControllerDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertFluxReconciliation(t, clientset)
	AssertK8sDeployment(t, clientset, "flux-system", "helm-controller", 1)
}

func TestFluxKustomizeControllerDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertFluxReconciliation(t, clientset)
	AssertK8sDeployment(t, clientset, "flux-system", "kustomize-controller", 1)
}

func TestFluxNotificationControllerDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertFluxReconciliation(t, clientset)
	AssertK8sDeployment(t, clientset, "flux-system", "notification-controller", 1)
}

func TestFluxSourceControllerDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertFluxReconciliation(t, clientset)
	AssertK8sDeployment(t, clientset, "flux-system", "source-controller", 1)
}
