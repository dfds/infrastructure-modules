package main

import "testing"

func TestAtlantisStatefulSet(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertStatefulSet(t, clientset, "atlantis", "atlantis", 1)
}
