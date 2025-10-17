package main

import "testing"

func TestKedaDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDeployment(t, clientset, "keda", "keda-operator", 3)
	AssertK8sDeployment(t, clientset, "keda", "keda-operator-metrics-apiserver", 3)
	AssertK8sDeployment(t, clientset, "keda", "keda-admission-webhooks", 3)
}
