package main

import "testing"

func TestKyvernoDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDeployment(t, clientset, "kyverno", "kyverno-admission-controller", 3)
	AssertK8sDeployment(t, clientset, "kyverno", "kyverno-background-controller", 1)
	AssertK8sDeployment(t, clientset, "kyverno", "kyverno-cleanup-controller", 1)
	AssertK8sDeployment(t, clientset, "kyverno", "kyverno-reports-controller", 1)
}
