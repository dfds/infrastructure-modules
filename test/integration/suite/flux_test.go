package main

import (
	"log"
	"testing"
	"time"

	v1 "k8s.io/api/core/v1"
)

var fluxReconciliationRequested time.Time

func initFlux() {
	var err error
	fluxReconciliationRequested, err = TriggerFluxReconcillation("kustomizations", "flux-system", "flux-system")
	if err != nil {
		log.Fatal("Error while triggering reconcillation:", err)
	}
	log.Println("Flux reconcillation requested")
}

func TestFluxHelmControllerDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	regarding := v1.ObjectReference{Kind: "Kustomization", Name: "flux-system"}
	AssertK8sEvent(t, clientset, "flux-system", "Normal", "ReconciliationSucceeded", regarding, fluxReconciliationRequested)
	AssertK8sDeployment(t, clientset, "flux-system", "helm-controller", 1)
}

func TestFluxKustomizeControllerDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	regarding := v1.ObjectReference{Kind: "Kustomization", Name: "flux-system"}
	AssertK8sEvent(t, clientset, "flux-system", "Normal", "ReconciliationSucceeded", regarding, fluxReconciliationRequested)
	AssertK8sDeployment(t, clientset, "flux-system", "kustomize-controller", 1)
}

func TestFluxNotificationControllerDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	regarding := v1.ObjectReference{Kind: "Kustomization", Name: "flux-system"}
	AssertK8sEvent(t, clientset, "flux-system", "Normal", "ReconciliationSucceeded", regarding, fluxReconciliationRequested)
	AssertK8sDeployment(t, clientset, "flux-system", "notification-controller", 1)
}

func TestFluxSourceControllerDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	regarding := v1.ObjectReference{Kind: "Kustomization", Name: "flux-system"}
	AssertK8sEvent(t, clientset, "flux-system", "Normal", "ReconciliationSucceeded", regarding, fluxReconciliationRequested)
	AssertK8sDeployment(t, clientset, "flux-system", "source-controller", 1)
}
