package main

import "testing"

func TestCoreDnsDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDeployment(t, clientset, "kube-system", "coredns", 2)
}
