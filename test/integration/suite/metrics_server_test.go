package main

import "testing"

func TestMetricsServerDeployment(t *testing.T) {
	t.Parallel()
	clientset := NewK8sClientSet(t)
	AssertK8sDeployment(t, clientset, "metrics-server", "metrics-server", 1)
}
