package main

import "testing"

func TestCoreDnsDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDeploymentWithScaling(t, clientset, "kube-system", "coredns", 2)
}
