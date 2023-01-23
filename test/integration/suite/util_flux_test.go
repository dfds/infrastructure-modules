package main

import (
	"time"

	fluxmeta "github.com/fluxcd/pkg/apis/meta"
	"k8s.io/apimachinery/pkg/runtime/schema"
)

func TriggerFluxReconcillation(resource, namespace, name string) (time.Time, error) {
	gvr := schema.GroupVersionResource{
		Group:    "kustomize.toolkit.fluxcd.io",
		Version:  "v1beta2",
		Resource: resource,
	}

	// Set annotation with reconciliation request timestamp
	requestTime := time.Now()
	return requestTime, SetK8sAnnotation(gvr, namespace, name,
		fluxmeta.ReconcileRequestAnnotation, requestTime.Format(time.RFC3339Nano))
}
