package main

import "testing"

func TestExternalSecretsDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDeployment(t, clientset, "external-secrets", "external-secrets", 1)
	AssertK8sDeployment(t, clientset, "external-secrets", "external-secrets-webhook", 1)
	AssertK8sDeployment(t, clientset, "external-secrets", "external-secrets-cert-controller", 1)
}
