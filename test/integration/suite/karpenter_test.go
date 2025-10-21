package main

import "testing"

func TestKarpentersDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDeployment(t, clientset, "karpenter", "karpenter", 2)
}
