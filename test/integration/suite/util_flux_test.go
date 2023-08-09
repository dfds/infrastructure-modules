package main

import (
	"log"
	"testing"
	"time"

	fluxmeta "github.com/fluxcd/pkg/apis/meta"
	v1 "k8s.io/api/core/v1"
	"k8s.io/apimachinery/pkg/runtime/schema"
	"k8s.io/client-go/kubernetes"
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

func AssertFluxReconciliation(t *testing.T, clientset *kubernetes.Clientset) {
	regarding := v1.ObjectReference{Kind: "Kustomization", Name: "flux-system"}
	AssertK8sEvent(t, clientset, "flux-system", "Normal", "ReconciliationSucceeded", regarding, fluxReconciliationRequested)
}

func TriggerFluxReconcillation(resource, namespace, name string) (time.Time, error) {
	gvr := schema.GroupVersionResource{
		Group:    "kustomize.toolkit.fluxcd.io",
		Version:  "v1",
		Resource: resource,
	}

	// Set annotation with reconciliation request timestamp
	requestTime := time.Now()
	return requestTime, SetK8sAnnotation(gvr, namespace, name,
		fluxmeta.ReconcileRequestAnnotation, requestTime.Format(time.RFC3339Nano))
}
