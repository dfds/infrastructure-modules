package main

import "testing"

func TestCoreDnsDeployment(t *testing.T) {
	clientset := NewK8sClientSet(t)
	AssertDeployment(t, clientset, "kube-system", "coredns", 2)
}
