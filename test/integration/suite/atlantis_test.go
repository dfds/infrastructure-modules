package main

import "testing"

func TestAtlantisStatefulSet(t *testing.T) {
	t.Parallel()
	if !cfg.AtlantisDeploy {
		t.Skip("Atlantis not deployed in this environment")
	}
	clientset := NewK8sClientSet(t)
	AssertK8sStatefulSet(t, clientset, "atlantis", "atlantis", 1)
}
